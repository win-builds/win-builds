open Config.Package
open Lib

type source += Tarball of (string * string)
type source += WB of string
type source += Patch of string

module Patch = struct
  let get _ _ = ()
end

module Git = struct
  type fetch = { remote : string; obj: string; uri : string }
  type source +=
    | Fetch of fetch
    | Disk
    | HEAD
    | Obj of string

  let get _ _ = ()
  let ts id = infinity
end

module Tarball = struct
  let get (file, sha1) =
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
            | WB _
            | Tarball _ -> Tarball.get p x
            | Git.Fetch _ 
            | Git.Disk
            | Git.HEAD
            | Git.Obj _ -> Git.get p x
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
  | Git.Fetch { Git.remote = id }
  | Git.Obj id -> id, Git.ts id
  | Git.Disk
  | Git.HEAD -> "git-disk-is-always-more-recent", infinity
  | _ -> assert false

