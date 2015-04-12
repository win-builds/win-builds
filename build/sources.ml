open Config.Package
open Lib

type source += Tarball of (string * string)
type source += WB of string
type source += Patch of string

module Patch = struct
  let get _ _ = ()
end

module Git = struct
  type fetch = { remote : string; obj : string; uri : string }
  type kind =
    | Fetch of fetch
    | Disk
    | Obj of string
  type t = { tarball : string; dir : string; kind : kind }
  type source += T of t

  let get ~p ~obj ~tarball ~dir =
    let open Unix in
    let tarball = sources_dir_ize p tarball in
    let git_dir = sp "--git-dir=%s/.git" (sources_dir_ize p dir)  in
    let snd_in, fst_out = pipe () in
    set_close_on_exec snd_in;
    let git = run ~stdout:fst_out [| "git"; git_dir; "archive"; obj |] in
    close fst_out;
    clear_close_on_exec snd_in;
    let fd = openfile tarball [ O_WRONLY; O_CREAT ] 0o644 in
    let gzip = run ~stdin:snd_in ~stdout:fd [| "gzip"; "-1" |] in
    close snd_in;
    close fd;
    git ();
    gzip ()

  let get p ({ tarball; dir } as t) =
    match t.kind with
    | Fetch fetch -> (); get ~p ~obj:fetch.obj ~tarball ~dir
    | Disk -> get ~p ~obj:"HEAD" ~tarball ~dir
    | Obj obj -> get ~p ~obj:obj ~tarball ~dir

  let ts ({ tarball } as t) =
    match t.kind with
    | Fetch _ -> tarball, 0.
    | Obj _ -> tarball, 0.
    | Disk -> "git-disk-is-always-more-recent", 0.
end

module Tarball = struct
  let get (file, sha1) =
    let download ~file =
      run [| "wget"; "-O"; file; Filename.concat (Sys.getenv "MIRROR") file |] ()
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
        let res = (try
          run ~stdin:pipe_read [| "sha1sum"; "--status"; "--check"; "--strict" |] ();
          true
        with Failure _ ->
          false
        )
        in
        Unix.close pipe_read;
        res
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
    get_file ~tries:3 ~sha1 ~file

  let get p = function
    | Tarball (file0, sha1) ->
        let file = sources_dir_ize p file0 in
        Lib.(log dbg " %s -> source=%s\n%!" p.package file);
        get (file, sha1)
    | WB file0 ->
        get (sources_dir_ize p file0, "")
    | _ ->
        assert false

  let ts file =
    Unix.handle_unix_error (fun file -> (Unix.lstat file).Unix.st_mtime) file
end

let get =
  let chan_send = Event.new_channel () in
  let chan_ack = Event.new_channel () in
  ignore (Thread.create (fun () ->
    while true do
      Event.sync (Event.send chan_ack (
        try
          let p = Event.sync (Event.receive chan_send) in
          ListLabels.iter p.sources ~f:(fun x -> match x with
            | WB _ -> ()
            | Tarball _ -> Tarball.get p x
            | Git.T y -> Git.get p y
            | Patch _ -> Patch.get p x
            | _ -> assert false
          );
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

let timestamp = function
  | Patch patch -> patch, 0.
  | WB file
  | Tarball (file, _) -> file, Tarball.ts file
  | Git.T x -> Git.ts x
  | _ -> assert false

let substitute_variables_sources ~dict source =
  let subst s = substitute_variables ~dict s in
  match source with
  | WB file -> WB (subst file)
  | Patch file -> Patch (subst file)
  | Tarball (file, s) -> Tarball (subst file, s)
  | Git.T ({ Git.tarball } as x) -> Git.(T { x with tarball = subst tarball })
  | x -> x

