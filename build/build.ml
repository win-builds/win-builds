open Config
open Config.Builder
open Lib

let name p =
  match p.variant with
  | Some variant -> String.concat ":" [ p.package; variant ]
  | None -> p.package

module B = struct
  let needs_rebuild ~sources ~output =
    let get_file file =
      if not (Sys.file_exists file) then
        try
          let i = String.index file '/' in
          let dir = String.sub file 0 i in
          let file = String.sub file (i+1) (String.length file - (i+1)) in
          run [|
            "git";
            Lib.sp "--git-dir=%s/.git" dir;
            Lib.sp "--work-tree=%s" dir;
            "checkout";
            Lib.sp "origin/tarballs-%s" Args.version_short;
            file
          |]
        with _ ->
          ()
    in
    let mod_time_err prev file =
      get_file file;
      Unix.handle_unix_error (fun () ->
        max prev (Unix.lstat file).Unix.st_mtime
      ) ()
    in
    let mod_time_opt file =
      try (Unix.lstat file).Unix.st_mtime with _ -> 0.
    in
    (List.fold_left mod_time_err 0. sources) > (mod_time_opt output)

  let build_one builder =
    run [| "mkdir"; "-p"; builder.yyoutput; builder.logs |];
    let env = env builder in
    (if not (Sys.file_exists builder.prefix.Prefix.yyprefix)
      || Sys.readdir builder.prefix.Prefix.yyprefix = [| |] then
      run [| "yypkg"; "--init"; "--prefix"; builder.prefix.Prefix.yyprefix |]);
    fun p ->
      let output = Filename.concat builder.yyoutput p.output in
      let sources_dir_ize = Filename.concat (Filename.concat p.dir p.package) in
      let sources = (List.map sources_dir_ize p.sources) in
      if
        p.dir = ""
        || (fun b -> (if b then progress "%s already up-to-date.\n%!" p.package); b) (not (needs_rebuild ~sources ~output))
      then
        ()
      else (
        progress "[%s] Building %s\n%!" builder.prefix.Prefix.nickname (name p);
        let dir = Filename.concat p.dir p.package in
        let variant = match p.variant with None -> "" | Some s -> "-" ^ s in
        let log =
          let filename = Filename.concat builder.logs (name p) in
          let flags = [ Unix.O_RDWR; Unix.O_CREAT; Unix.O_TRUNC ] in
          Unix.openfile filename flags 0o644
        in
        let run command = run ~stdout:log ~stderr:log ~env command in
        run [|
          "sh"; "-cex";
          String.concat "; " [
            sp "cd %S" dir;
            sp "export DESCR=\"$(sed -n 's;^[^:]\\+: ;; p' slack-desc | sed -e 's;\";\\\\\\\\\";g' -e 's;/;\\\\/;g' | tr '\\n' ' ')\"";
            sp "export PREFIX=\"$(echo \"${YYPREFIX}\" | sed 's;^/;;')\"";
            sp "export VERSION=%S" p.version;
            sp "export BUILD=%d" p.build;
            sp "if [ -e config%s ]; then . ./config%s; fi" variant variant;
            sp "exec bash -x %s.SlackBuild" p.package
          ]
        |];
        run [| "yypkg"; "--upgrade"; "--install-new"; output |];
        Unix.close log
      )
end

let build ~failer builder =
  let something_to_do =
    try
      let l = Sys.getenv (String.uppercase builder.name) in
      ignore (Str.search_forward (Str.regexp "[^,]") l 0);
      true
    with _ ->
      false
  in
  if something_to_do then (
    let packages = List.filter (fun p -> p.to_build) builder.packages in
    (if packages <> [] then (
      progress "[%s] Building %s\n%!"
        builder.prefix.Prefix.nickname
        (String.concat ", " (List.map name packages));
      ListLabels.iter packages ~f:(fun p ->
        let res = (try B.build_one builder p; true with _ -> false) in
        if !failer then
          failwith "Aborting because another thread did so."
        else (
          if not res then (
            failer := true;
            failwith "Aborting because build failed."
          )
        )
      );
    ));
    progress "[%s] Setting up repository.\n%!" builder.prefix.Prefix.nickname;
    try
      run [| "yypkg"; "--repository"; "--generate"; builder.yyoutput |]
    with _ -> Printf.eprintf "ERROR: Couldn't create repository!\n%!"
  )
  else
    ()

(* This is the only acceptable umask when building packets. Any other gives
 * wrong permissions in the packages, like 711 for /usr, and will break
 * systems. *)
let () = ignore (Unix.umask 0o022)

let () =
  let build builders =
    let failer = ref false in
    List.iter Thread.join (List.map (Thread.create (build ~failer)) builders);
    (if !failer then failwith "Build failed.")
  in
  List.iter build [
    [ Native_toolchain.builder ];
    [ Cross_toolchain.builder_32; Cross_toolchain.builder_64 ];
    [ Windows.builder_32; Windows.builder_64 ];
  ]
