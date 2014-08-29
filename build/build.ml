open Config
open Config.Builder
open Lib

let name p =
  match p.variant with
  | Some variant -> String.concat ":" [ p.package; variant ]
  | None -> p.package

module B = struct
  let needs_rebuild ~sources ~outputs =
    let file_matches_sha1 ~sha1 ~file =
      if sha1 = "" then
        true
      else
        let pipe_read, pipe_write = Unix.pipe () in
        let line = Lib.sp "%s *%s\n" sha1 file in
        let l = String.length line in
        assert (l = Unix.write pipe_write line 0 l);
        Unix.close pipe_write;
        try
          run ~stdin:pipe_read [| "sha1sum"; "--status"; "--check"; "--strict" |];
          true
        with Failure _ ->
          false
    in
    let download ~file =
      run [| "wget"; "-O"; file; Filename.concat (Sys.getenv "MIRROR") file |]
    in
    let rec get_file ?(tries=0) ~sha1 ~file =
      let retry () =
        log cri "Failed retrieving file %S (SHA1=%s).\n" file sha1;
        if tries > 1 then (
          log cri "Trying again: %d attempt(s) left.\n" tries;
          get_file ~tries:(tries-1) ~sha1 ~file
        )
        else (
          log cri "No attempt left.\nFAILED!\n";
          (try Sys.remove file with Sys_error _ -> ());
          failwith (Lib.sp "Download of %S (SHA1=%s)." file sha1)
        )
      in
      let matches =
        try
          (if not (Sys.file_exists file) then download ~file);
          file_matches_sha1 ~sha1 ~file
        with
          _ -> false
      in
      if not matches then
        retry ()
      else
        ()
    in
    let mod_time_err prev (file, sha1) =
      (if sha1 <> "" then
        get_file ~tries:3 ~sha1 ~file
      );
      Unix.handle_unix_error (fun () ->
        max prev (Unix.lstat file).Unix.st_mtime
      ) ()
    in
    let mod_time_opt prev file =
      max prev (try (Unix.lstat file).Unix.st_mtime with _ -> 0.)
    in
    (* TODO: collect all the files that are more recent *)
    let mod_time_sources = List.fold_left mod_time_err 0. sources in
    let mod_time_outputs = List.fold_left mod_time_opt 0. outputs in
    if mod_time_sources > mod_time_outputs then (
      log dbg "One of %s is more recent than the output.\n%!"
        (String.concat ", " (List.map fst sources));
      true
    )
    else
      false


  let build_one builder =
    run [| "mkdir"; "-p"; builder.yyoutput; builder.logs |];
    let env = env builder in
    (if not (Sys.file_exists builder.prefix.Prefix.yyprefix)
      || Sys.readdir builder.prefix.Prefix.yyprefix = [| |] then
      run [| "yypkg"; "--init"; "--prefix"; builder.prefix.Prefix.yyprefix |]);
    fun p ->
      let outputs = List.map (Filename.concat builder.yyoutput) p.outputs in
      let sources_dir_ize = Filename.concat (Filename.concat p.dir p.package) in
      let sources = List.map (fun (f, s) -> sources_dir_ize f, s) p.sources in
      if p.dir = "" || not (needs_rebuild ~sources ~outputs) then
        fun () ->
          progress "[%s] %s is already up-to-date.\n%!" builder.prefix.Prefix.nickname (name p)
      else
        fun () -> (
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
          ListLabels.iter outputs ~f:(fun output ->
            run [| "yypkg"; "--upgrade"; "--install-new"; output |]
          );
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
      progress "[%s] Building: %s\n%!"
        builder.prefix.Prefix.nickname
        (String.concat ", " (List.map name packages));
      let p_builds = List.map (fun p -> p, B.build_one builder p) packages in
      ListLabels.iter p_builds ~f:(fun (p, p_build) ->
        let res = (try p_build (); true with _ -> false) in
        if !failer then
          failwith "Aborting because another thread did so."
        else (
          if not res then (
            failer := true;
            failwith ("Build of " ^ p.package ^ " failed.")
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
