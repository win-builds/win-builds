open Config
open Config.Builder
open Lib

let name p =
  match p.variant with
  | Some variant -> String.concat ":" [ p.package; variant ]
  | None -> p.package

module B = struct
  let get_files l =
    let download ~file =
      run [| "wget"; "-O"; file; Filename.concat (Sys.getenv "MIRROR") file |]
    in
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
    ListLabels.iter l ~f:(fun (file, sha1) ->
      if sha1 <> "" then get_file ~tries:3 ~sha1 ~file
    )

  let get_files =
    let chan_send = Event.new_channel () in
    let chan_ack = Event.new_channel () in
    ignore (Thread.create (fun () ->
      while true do
        Event.sync (Event.send chan_ack (
          try
            get_files (Event.sync (Event.receive chan_send));
            None
          with exn ->
            Some exn
        ))
      done
    ) ());
    (fun l ->
      Event.sync (Event.send chan_send l);
      match Event.sync (Event.receive chan_ack) with
      | None -> ()
      | Some exn -> raise exn)

  let needs_rebuild ~sources ~outputs =
    let ts_err file =
      Unix.handle_unix_error (fun () ->
        (Unix.lstat file).Unix.st_mtime
      ) ()
    in
    let ts_opt file =
      try (Unix.lstat file).Unix.st_mtime with _ -> 0.
    in
    let ts_sources = List.map (fun (file, _) -> file, ts_err file) sources in
    let ts_outputs = List.map (fun file -> file, ts_opt file) outputs in
    let assoc_data_fold_left f = List.fold_left (fun p (_k, v) -> f p v) in
    let ts_sources_max = assoc_data_fold_left max 0. ts_sources in
    let ts_outputs_min = assoc_data_fold_left min infinity ts_outputs in
    if ts_outputs_min < ts_sources_max then (
      (* TODO: these log messages need context but it's really annoying to do
        * without a better log function which requires ikfprintf which requires
        * ocaml 4.00 so for now... *)
      (if ts_outputs = [] then
        ()
        (* log inf "Output doesn't exist.\n%!" *)
      else
        let l = List.filter (fun (_f, ts) -> ts > ts_outputs_min) ts_sources in
        log inf "Output is older than %s.\n%!"
          (String.concat ", " (List.map (fun f -> Filename.basename (fst f)) l))
      );
      true
    )
    else
      false

  let build_one ~env ~builder p =
    let outputs = List.map (Filename.concat builder.yyoutput) p.outputs in
    let sources_dir_ize = Filename.concat (Filename.concat p.dir p.package) in
    let sources = List.map (fun (f, s) -> sources_dir_ize f, s) p.sources in
    get_files sources;
    if p.dir = "" || not (needs_rebuild ~sources ~outputs) then (
      progress "[%s] %s is already up-to-date.\n%!" builder.prefix.Prefix.nickname (name p)
    )
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
      (try
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
      with e ->
        ListLabels.iter outputs ~f:(fun output ->
          try Unix.unlink output with _ -> ()
        );
        Unix.close log;
        raise e
      );
      ListLabels.iter outputs ~f:(fun output ->
        run [| "yypkg"; "--upgrade"; "--install-new"; output |]
      );
      Unix.close log
    )

  let build_env builder =
    run [| "mkdir"; "-p"; builder.yyoutput; builder.logs |];
    let env = env builder in
    (if not (Sys.file_exists builder.prefix.Prefix.yyprefix)
      || Sys.readdir builder.prefix.Prefix.yyprefix = [| |] then
    (
      let version = Sys.getenv "VERSION" in
      run ~env [| "yypkg"; "--init" |];
      run ~env [| "yypkg"; "--config"; "--predicates"; "--set";
        Lib.sp "host=%s" builder.prefix.Prefix.host.Arch.triplet |];
      run ~env [| "yypkg"; "--config"; "--predicates"; "--set";
        Lib.sp "target=%s" builder.prefix.Prefix.target.Arch.triplet |];
      run ~env [| "yypkg"; "--config"; "--set-mirror";
        Lib.sp "http://win-builds.org/%s/packages/windows_%d"
          version builder.prefix.Prefix.host.Arch.bits |];
    ));
    env
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
      progress "[%s] Checking %s\n%!"
        builder.prefix.Prefix.nickname
        (String.concat ", " (List.map name packages));
      let env = B.build_env builder in
      let rec aux = function
        | { package = "download" } :: tl ->
            run ~env [| "yypkg"; "--web"; "--auto"; "yes" |];
            aux tl
        | p :: tl ->
            if not (try B.build_one ~builder ~env p; true with _ -> false) then(
              failer := true;
              Some ("Build of " ^ p.package ^ " failed.")
            )
            else (
              if !failer then
                Some "Aborting because another thread did so."
              else
                aux tl
            )
        | [] ->
            None
      in
      may prerr_endline (aux packages);
    ));
    if try (Sys.readdir builder.yyoutput) <> [| |] with _ -> false then (
      progress "[%s] Setting up repository.\n%!" builder.prefix.Prefix.nickname;
      try
        run [| "yypkg"; "--repository"; "--generate"; builder.yyoutput |]
      with _ -> Printf.eprintf "ERROR: Couldn't create repository!\n%!"
    )
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
