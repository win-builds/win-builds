module Env = struct
  type t =
    | Prepend of string list
    | Set of string list
    | Clear
    | Keep

  module M = Map.Make (String)

  let get () =
    ArrayLabels.fold_left (Unix.environment ()) ~init:M.empty ~f:(fun m s ->
      let i = String.index s '=' in
      M.add (String.sub s 0 i) (String.sub s (i+1) (String.length s - (i+1))) m
    )

  let to_array env =
    let a = Array.of_list (M.bindings env) in
    Array.map (fun (b, v) -> String.concat "=" [ b; v ]) a

  let process env ts =
    ListLabels.fold_left ts ~init:env ~f:(fun env (name, action) ->
      (* TODO: separator is not always ':' *)
      match action with
      | Prepend l ->
          if M.mem name env then
            let v = M.find name env in
            M.add name (Lib.sp "%s:%s" (String.concat ":" l) v) env
          else
            M.add name (String.concat ":" l) env
      | Set l ->
          M.add name (String.concat ":" l) env
      | Clear ->
          M.remove name env
      | Keep ->
          env
    )
end

module Arch = struct
  type t = {
    triplet : string;
    bits : int;
    strip : string;
    exe_format : string;
  }

  let slackware = {
    triplet = "x86_64-slackware-linux";
    bits = 64; (* XXX *)
    strip = "strip";
    exe_format = "ELF";
  }

  let windows_32 = {
    triplet = "i686-w64-mingw32";
    bits = 32;
    strip = "i686-w64-mingw32-strip";
    exe_format = "PE";
  }

  let windows_64 = {
    triplet = "x86_64-w64-mingw32";
    bits = 64;
    strip = "x86_64-w64-mingw32-strip";
    exe_format = "PE";
  }
end

module Prefix = struct
  type t = {
    yyprefix : string;
    libdir : string;
    nickname : string;
    kind : string;
    build : Arch.t;
    host : Arch.t;
    target : Arch.t;
  }

  let t ~build ~host ~target =
    let nickname, kind = (* FIXME *)
      if build = host then
        if build = target then
          "native_toolchain", "native_toolchain"
        else
          Lib.sp "cross_toolchain_%d" target.Arch.bits, "cross_toolchain"
      else
        Lib.sp "windows_%d" host.Arch.bits, "windows"
    in
    let path = "/opt/" ^ nickname in
    let libdir =
      Filename.concat path (if target.Arch.bits = 32 then "lib" else "lib64")
    in
    { build; host; target; nickname; kind; yyprefix = path; libdir }
end

module Builder = struct
  type package = {
    dir : string;
    package : string;
    variant : string option;
    dependencies : package list;
    version : string;
    build : int;
    sources : string list;
    output : string;
    mutable to_build : bool;
  }

  type t = {
    name : string;
    prefix : Prefix.t;
    path : Env.t;
    pkg_config_path : Env.t;
    pkg_config_libdir : Env.t;
    logs : string;
    yyoutput : string;
    tmp : Env.t;
    mutable native_prefix : string option;
    mutable target_prefix : string option;
    mutable packages : package list;
  }

  let env t =
    let module P = Prefix in
    let module A = Arch in
    let build = t.prefix.P.build in
    let host = t.prefix.P.host in
    let target = t.prefix.P.target in
    Env.to_array (Env.process (Env.get ()) [
      "PATH", t.path;
      "PKG_CONFIG_PATH", t.pkg_config_path; (* FIXME: base on libdir *)
      "PKG_CONFIG_LIBDIR", t.pkg_config_libdir; (* FIXME: base on libdir *)
      "YYPREFIX", Env.Set [ t.prefix.P.yyprefix ];
      (* "PREFIX", Env.Set [ Str.(replace_first (regexp "/") "" prefix) ]; *)
      "YYOUTPUT", Env.Set [ t.yyoutput ];
      "TMP", t.tmp;
      "LIBDIRSUFFIX", Env.Set [ if host.A.bits = 64 then "64" else "" ];
      "HOST_EXE_FORMAT", Env.Set [ host.A.exe_format ];
      "TARGET_EXE_FORMAT", Env.Set [ target.A.exe_format ];
      "BUILD_EXE_FORMAT", Env.Set [ build.A.exe_format ];
      "HOST_STRIP", Env.Set [ host.A.strip ];
      "TARGET_STRIP", Env.Set [ target.A.strip ];
      "BUILD_STRIP", Env.Set [ build.A.strip ];
      "HOST_TRIPLET", Env.Set [ host.A.triplet ];
      "TARGET_TRIPLET", Env.Set [ target.A.triplet ];
      "BUILD_TRIPLET", Env.Set [ build.A.triplet ];
      "YYPREFIX_NATIVE",
        (match t.native_prefix with Some p -> Env.Set [ p ] | None -> Env.Keep);
      "YYPREFIX_TARGET",
        (match t.target_prefix with Some p -> Env.Set [ p ] | None -> Env.Keep);
    ])

  let logs_yyoutput ~nickname =
    let rel_path l = Lib.filename_concat (Args.work_dir :: l) in
    rel_path [ "logs"; nickname ],
    rel_path [ "packages"; nickname ]

  let bindir prefix =
    Filename.concat prefix.Prefix.yyprefix "bin"

  let substitute_variables ~dict s =
    let f k =
      try
        List.assoc k dict
      with Not_found as exn ->
        Lib.log Lib.cri "Couldn't resolve variable %S.\n%!" k;
        raise exn
    in
    let b = Buffer.create (String.length s) in
    Buffer.add_substitute b f s;
    Buffer.contents b

  let shall_build builder_name =
    let l = try Sys.getenv (String.uppercase builder_name) with Not_found -> "all" in
    let h = Hashtbl.create 200 in
    ListLabels.iter (Str.split (Str.regexp ",") l) ~f:(fun e ->
      match Str.split (Str.regexp ":") e with
      | [ n; v ] -> Hashtbl.add h (n, Some v) true
      | [ n ] -> Hashtbl.add h (n, None) true
      | _ -> assert false
    );
    fun p -> Hashtbl.mem h (p.package, p.variant)

  let add
      ~push ~builder
      (package, variant)
      ~dir ~dependencies ~version ~build ~sources
    =
    let shall_build = shall_build builder.name in
    let rec colorize p =
      if not p.to_build then (
        p.to_build <- true;
        List.iter colorize p.dependencies
      )
    in
    let dict = [
      "PACKAGE", package;
      "VARIANT", (match variant with Some v -> v | None -> "");
      "VERSION", version;
      "BUILD", string_of_int build;
      "TARGET_TRIPLET", builder.prefix.Prefix.target.Arch.triplet;
      "HOST_TRIPLET", builder.prefix.Prefix.host.Arch.triplet;
      "BUILD_TRIPLET", builder.prefix.Prefix.build.Arch.triplet;
    ] in
    let add_aux p = (if shall_build p then colorize p); push p; p in
    let output = 
      if builder.prefix.Prefix.target <> builder.prefix.Prefix.host then
        "${PACKAGE}-${VERSION}-${BUILD}-${TARGET_TRIPLET}-${HOST_TRIPLET}.txz"
      else
        "${PACKAGE}-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz"
    in
    let sources =
      "${PACKAGE}.SlackBuild"
      :: "${PACKAGE}.yypkg.script"
      :: "slack-desc"
      :: sources
    in
    let sources =
      match variant with
      | Some variant -> ("config-" ^ variant) :: sources
      | None -> sources
    in
    add_aux {
      package; variant; dir; dependencies;
      version; build;
      sources = List.map (substitute_variables ~dict) sources;
      output = substitute_variables ~dict output;
      to_build = false;
    }

  let register ~builder =
    add ~builder ~push:(fun p -> builder.packages <- (builder.packages @ [p]))
end
