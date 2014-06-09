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
  type t = {
    prefix : Prefix.t;
    path : Env.t;
    pkg_config_path : Env.t;
    pkg_config_libdir : Env.t;
    logs : string;
    yyoutput : string;
    tmp : Env.t;
    mutable native_prefix : string option;
    mutable target_prefix : string option;
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

  let logs_yyoutput ~nickname ~host ~target =
    let rel_path l = Lib.filename_concat (Args.work_dir :: l) in
    rel_path [ "logs"; nickname ],
    rel_path [ "packages"; nickname ]

  let bindir prefix =
    Filename.concat prefix.Prefix.yyprefix "bin"

  let native =
    let build = Arch.slackware in
    let host = Arch.slackware in
    let target = Arch.slackware in
    let prefix = Prefix.t ~build ~host ~target in
    let logs, yyoutput = logs_yyoutput
      ~nickname:prefix.Prefix.nickname ~host ~target in
    let open Arch in
    let open Prefix in
    {
      prefix; logs; yyoutput;
      path = Env.Prepend [ bindir prefix ];
      pkg_config_path = Env.Prepend [ Filename.concat prefix.libdir "pkgconfig" ];
      pkg_config_libdir = Env.Keep;
      tmp = Env.Set [ Filename.concat prefix.Prefix.yyprefix "tmp" ];
      target_prefix = None; native_prefix = None;
    }

  let cross arch =
    let build = Arch.slackware in
    let host = Arch.slackware in
    let target = arch in
    let prefix = Prefix.t ~build ~host ~target in
    let logs, yyoutput = logs_yyoutput
      ~nickname:prefix.Prefix.nickname ~host ~target in
    let open Arch in
    let open Prefix in
    {
      prefix; logs; yyoutput;
      path = Env.Prepend [ bindir prefix; bindir native.prefix ];
      pkg_config_path = Env.Prepend [ Filename.concat prefix.libdir "pkgconfig" ];
      pkg_config_libdir = Env.Keep;
      tmp = Env.Set [ Filename.concat prefix.Prefix.yyprefix "tmp" ];
      target_prefix = None; native_prefix = None;
    }

  let windows ~cross arch =
    let build = Arch.slackware in
    let host = arch in
    let target = arch in
    let prefix = Prefix.t ~build ~host ~target in
    let logs, yyoutput = logs_yyoutput
      ~nickname:prefix.Prefix.nickname ~host ~target in
    cross.target_prefix <- Some prefix.Prefix.yyprefix;
    let open Arch in
    let open Prefix in
    {
      prefix; logs; yyoutput;
      path = Env.Prepend [ bindir cross.prefix; bindir native.prefix ];
      pkg_config_path = Env.Clear;
      pkg_config_libdir = Env.Set [ Filename.concat prefix.libdir "pkgconfig" ] ;
      tmp = Env.Set [ Filename.concat prefix.Prefix.yyprefix "tmp" ];
      target_prefix = None; native_prefix = Some native.prefix.Prefix.yyprefix;
    }
end
