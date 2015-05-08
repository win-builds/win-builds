open Config.Package
open Config.Builder
open Config.Prefix
open Config.Arch
open Sources

open Lib

let needs_rebuild ~sources ~outputs =
  let ts_outputs = ListLabels.map outputs ~f:(fun file ->
    file, (try Unix.((lstat file).st_mtime) with _ -> 0.)
  )
  in
  let ts_sources = List.map Sources.timestamp sources in
  let assoc_data_fold_left f = List.fold_left (fun p (_k, v) -> f p v) in
  let ts_outputs_min = assoc_data_fold_left min infinity ts_outputs in
  let ts_sources_max = assoc_data_fold_left max 0. ts_sources in
  if ts_outputs_min < ts_sources_max then (
    (* TODO: these log messages need context but it's really annoying to do
      * without a better log function which requires ikfprintf which requires
      * ocaml 4.00 so for now... *)
    let l = List.filter (fun (_f, ts) -> ts > ts_outputs_min) ts_sources in
    log inf "Output is older than %s.\n%!"
      (String.concat ", " (List.map (fun f -> Filename.basename (fst f)) l));
    true
  )
  else
    false

let run_build_shell ~devshell ~run p =
  let dir = Filename.concat p.dir p.package in
  let variant = match p.variant with None -> "" | Some s -> "-" ^ s in
  run [|
    "sh"; "-cex";
    String.concat "; " [
      sp "cd %S" dir;
      sp "export DESCR=\"$(sed -n 's;^[^:]\\+: ;; p' slack-desc | sed -e 's;\";\\\\\\\\\";g' -e 's;/;\\\\/;g' | tr '\\n' ' ')\"";
      sp "export PREFIX=\"$(echo \"${YYPREFIX}\" | sed 's;^/;;')\"";
      sp "export VERSION=%S" p.version;
      sp "export BUILD=%d" p.build;
      sp "if [ -e config%s ]; then . ./config%s; fi" variant variant;
      if not devshell then
        sp "exec bash -x %s.SlackBuild" p.package
      else
        sp "exec /bin/bash --norc"

    ]
  |] ()

let build_one_package ~builder ~outputs ~env p =
  let log =
    let filename = Filename.concat builder.logs (to_name p) in
    let flags = [ Unix.O_RDWR; Unix.O_CREAT; Unix.O_TRUNC ] in
    Unix.openfile filename flags 0o644
  in
  let run command = run ~stdout:log ~stderr:log ~env command in
  (try run_build_shell ~devshell:false ~run p with e ->
    List.iter (fun output -> try Unix.unlink output with _ -> ()) outputs;
    Unix.close log;
    raise e
  );
  ListLabels.iter outputs ~f:(fun output ->
    run [| "yypkg"; "--upgrade"; "--install-new"; output |] ()
  );
  Unix.close log

let build_one_devshell ~env p =
  run_build_shell ~devshell:true ~run:(run ~env) p

let build_one ~env ~builder p =
  let outputs = List.map (Filename.concat builder.yyoutput) p.outputs in
  Sources.get p;
  if p.devshell then
    build_one_devshell ~env p
  else (
    if not (needs_rebuild ~sources:p.sources ~outputs) then (
      progress "[%s] %s is already up-to-date.\n%!" builder.prefix.nickname (to_name p)
    )
    else (
      progress "[%s] Building %s\n%!" builder.prefix.nickname (to_name p);
      build_one_package ~builder ~outputs ~env p)
  )

let build_env builder =
  run ~env:[||] [| "mkdir"; "-p"; builder.yyoutput; builder.logs |] ();
  let env = env builder in
  (if not (Sys.file_exists builder.prefix.yyprefix)
    || Sys.readdir builder.prefix.yyprefix = [| |] then
  (
    run ~env [| "yypkg"; "--init" |] ();
    run ~env [| "yypkg"; "--config"; "--predicates"; "--set";
      Lib.sp "host=%s" builder.prefix.host.triplet |] ();
    run ~env [| "yypkg"; "--config"; "--predicates"; "--set";
      Lib.sp "target=%s" builder.prefix.target.triplet |] ();
    run ~env [| "yypkg"; "--config"; "--set-mirror";
      Lib.sp "http://win-builds.org/%s/packages/windows_%d"
        Lib.version builder.prefix.host.bits |] ();
  ));
  env

let add ~push ~builder =
  let shall_build = shall_build builder.name in
  let add_cross_builder_deps ~builder_name l =
    let v = String.uppercase builder_name in
    let new_deps = String.concat "," l in
    let cur = try Sys.getenv v with Not_found -> "" in
    Unix.putenv v (String.concat "," [ cur; new_deps ])
  in
  let rec colorize p =
    if not p.to_build then (
      p.to_build <- true;
      add_cross_builder_deps ~builder_name:"native_toolchain" p.native_deps;
      may (fun n -> add_cross_builder_deps ~builder_name:n p.cross_deps)
        builder.cross_name;
      List.iter colorize p.dependencies
    )
  in
  let add_aux p = (if shall_build p then colorize p); push p; p in
  let default_output () =
    if builder.prefix.target <> builder.prefix.host then
      "${PACKAGE}-${VERSION}-${BUILD}-${TARGET_TRIPLET}-${HOST_TRIPLET}.txz"
    else
      "${PACKAGE}-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz"
  in
  fun
    ?(outputs = [ default_output () ])
    ?(native_deps = [])
    ?(cross_deps = builder.default_cross_deps)
    ~dir ~dependencies ~version ~build ~sources
    (package, variant)
  ->
    let is_virtual = (sources = []) in
    let s_of_variant ?(pref="") = function Some v -> pref ^ v | None -> "" in
    (if not is_virtual then (
      Lib.log Lib.dbg
        "Adding package %S %S %d.\n%!"
        (package ^ (s_of_variant ~pref:":" variant))
        version
        build;
    ));
    let dict = [
      "PACKAGE", package;
      "VARIANT", s_of_variant variant;
      "VERSION", version;
      "BUILD", string_of_int build;
      "TARGET_TRIPLET", builder.prefix.target.triplet;
      "HOST_TRIPLET", builder.prefix.host.triplet;
      "BUILD_TRIPLET", builder.prefix.build.triplet;
    ] in
    let sources =
      if dir <> "" then
        List.concat [
          (match variant with Some v -> [ WB ("config-" ^ v) ] | None -> []);
          [ WB "${PACKAGE}.SlackBuild" ];
          [ WB "${PACKAGE}.yypkg.script" ];
          sources
        ]
      else
        []
    in
    let sources = List.map (substitute_variables_sources ~dir ~package ~dict) sources in
    (if not is_virtual then (
      ListLabels.iter sources ~f:(function
        | Tarball (file, _) -> Lib.(log dbg " %s -> source=%s\n%!" package file)
        | _ -> ()
      )
    ));
    let p = {
      package; variant; dir; dependencies; native_deps; cross_deps;
      version; build;
      sources;
      outputs = List.map (substitute_variables ~dict) outputs;
      to_build = false;
      devshell = false;
    }
    in
    (* Automatically inject a "devshell" package and don't return it since it
     * makes no sense to have other packages depend on it. *)
    ignore (add_aux { p with devshell = true });
    add_aux p

let register ~builder =
  add ~builder ~push:(fun p -> builder.packages <- (builder.packages @ [p]))
