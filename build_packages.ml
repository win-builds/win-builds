type package = {
  dir : string;
  package : string;
  variant : string option;
  name : string;
}

module Lib = struct
  let cri = 0
  let err = 1
  let wrn = 2
  let dbg = 3

  let log level =
    let threshold =
      try
        match Sys.getenv "LOGLEVEL" with
        | "CRI" | "cri" -> cri
        | "ERR" | "err" -> err
        | "WRN" | "wrn" -> wrn
        | "DBG" | "dbg" -> dbg
        | s -> try int_of_string s with _ -> 0
      with _ -> 0
    in
    (if threshold >= level then Printf.fprintf else Printf.ifprintf) stderr

  let progress = Printf.eprintf

  let sp = Printf.sprintf

  type command = {
    cmd : string;
    pid : int;
  }

  let waitpid command =
    let f = log err in
    match snd (Unix.waitpid [] command.pid) with
    | Unix.WEXITED i ->
        f "Command `%s' returned %d.\n%!" command.cmd i;
        (* TODO: cancel other processes at once *)
        if i <> 0 then failwith (sp "Failed process [%d]: `%s'\n'" i command.cmd)
    | Unix.WSIGNALED i ->
        f "Command `%s' has been signaled with signal %d.\n%!" command.cmd i
    | Unix.WSTOPPED i ->
        f "Command `%s' has been stopped with signal %d.\n%!" command.cmd i

  let add_to_current_environment = function
    | None -> Unix.environment ()
    | Some env -> Array.concat [ env; Unix.environment () ]

  let create_process_sync ?(stdout=Unix.stdout) ?(stderr=Unix.stderr) ?env a =
    let cmd = String.concat " " (Array.to_list a) in
    progress "Running and waiting for `%s'.\n%!" cmd;
    let env = add_to_current_environment env in
    let pid = Unix.create_process_env a.(0) a env Unix.stdin stdout stderr in
    progress "Created process; pid: %d.\n\n%!" pid;
    waitpid { pid = pid; cmd = cmd }

  let create_process_async ?(stdout=Unix.stdout) ?(stderr=Unix.stderr) ?env a =
    let cmd = String.concat " " (Array.to_list a) in
    progress "Running `%s'.\n%!" cmd;
    let env = add_to_current_environment env in
    let pid = Unix.create_process_env a.(0) a env Unix.stdin stdout stderr in
    { pid = pid; cmd = cmd }

  let cp ~sources ~dest =
    create_process_sync (Array.concat [ [| "cp" |]; sources; [| dest |] ])

  let make_path_absolute_if_not path =
    let cwd = Sys.getcwd () in
    if Filename.is_relative path then
      Filename.concat cwd path
    else
      path

  let default ~default = function
    | Some x -> x
    | None -> default

  let may f = function
    | Some x -> f x
    | None -> ()

  let filename_concat l = List.fold_left Filename.concat "" l

  let rev_uniq l =
    let rec rev_uniq_rc accu cur = function
      | t :: q when t = cur -> rev_uniq_rc accu cur q
      | t :: q -> rev_uniq_rc (t :: accu) t q
      | [] -> accu
    in
    match l with
    | t :: q -> rev_uniq_rc [ t ] t q
    | [] -> []
end

module Options = struct
  let chroot = false
  let triplets = [ "i686-w64-mingw32"; "x86_64-w64-mingw32" ]
  let all_kinds = [ "native_toolchain"; "cross_toolchain"; "windows" ]
end

module Args = struct
  let args = Sys.argv

  let source_path = Lib.make_path_absolute_if_not (Filename.dirname args.(0))

  let work_dir =
    if Array.length args < 2 then (
      Lib.log Lib.cri "Not enough arguments.\n%!";
      exit 1
    )
    else
      let location = Lib.make_path_absolute_if_not args.(1) in
      if Options.chroot then
        Filename.concat location "system/root/yypkg_packages"
      else
        location

  let kinds =
    if Array.length args < 3 then
      Options.all_kinds
    else
      let kinds = Str.split (Str.regexp "-") args.(2) in
      ListLabels.fold_left kinds ~init:[] ~f:(fun kinds s ->
        if List.mem s Options.all_kinds && not (List.mem s kinds) then
          s :: kinds
        else
          kinds
      )

  let wishes =
    if Array.length args < 4 then (
      if List.length kinds = List.length Options.all_kinds then (
        Printf.printf "Warning. Going to build everything. This will take a while.\n";
        Printf.printf "You have 10 seconds to cancel.\n%!";
        Unix.sleep 10
      );
      []
    )
    else
      Array.to_list (Array.sub args 3 (Array.length args - 3))
end

open Lib
open Args

let filter ~kind ~available ~wishes =
  let available =
    if List.exists (fun k -> Str.string_match (Str.regexp k) kind 0) kinds then
      available
    else
      []
  in
  match wishes with
    | [] -> available
    | l -> List.filter (fun p -> List.mem p.name l) available

let prepare ~packages =
  if packages <> [] then (
    progress "Preparing: %s.\n%!"
      (String.concat ", " (List.map (fun p -> p.name) packages));
    create_process_sync [| "mkdir"; "-p"; work_dir |];
    let bd_files = [| "build_daemon"; "build_daemon_config" |] in
    let bd_files = Array.map (Filename.concat source_path) bd_files in
    cp ~dest:work_dir ~sources:bd_files;
    ListLabels.iter packages ~f:(fun p ->
      create_process_sync [|
        "tar"; "cf"; sp "%s/%s.tar" work_dir p.name;
        sp "--transform=s/\\<config-%s$/config/" (default ~default:"" p.variant);
        sp "--transform=s/\\<%s.SlackBuild$/%s.SlackBuild/" p.package p.name;
        "-C"; Filename.concat p.dir p.package; "."
      |]
    );
  )

let build ~work_dir ~kind ?env packages =
  if packages <> [] then (
    progress "Building: %s.\n%!"
      (String.concat ", " (List.map (fun p -> p.name) packages));
    if Options.chroot then
      assert false
    else (
      Some (create_process_async ?env (Array.concat [
        [| Filename.concat work_dir "build_daemon"; kind |];
        Array.map (fun p -> p.name) (Array.of_list packages)
      ]))
    )
  )
  else
    None

let parse_package_list file =
  let ic = open_in_bin (filename_concat [source_path; "package_list"; file]) in
  let rec aux accu =
    try
      let s = input_line ic in
      if String.length s < 1 || s.[0] = '#' then
        aux accu
      else
        let open Str in
        let re = regexp "^\\([^ ]+\\) \\([^ ]+\\)$" in
        if string_match re s 0 then
          let dir = matched_group 1 s in
          let s2 = matched_group 2 s in
          let re = regexp "^\\([^ ]+\\):\\([^ ]+\\)$" in
          if string_match re s2 0 then
            let p = matched_group 1 s2 in
            let v = matched_group 2 s2 in
            let name = String.concat "-" [ p; v ] in
            aux ({ dir; package = p; variant = Some v; name } :: accu)
          else
            aux ({ dir; package = s2; variant = None; name = s2 } :: accu)
        else (
          failwith (sp "Couldn't parse package list entry %S.\n" s);
        )
    with End_of_file -> List.rev accu
  in
  let l = aux [] in
  close_in ic;
  l

let () =
  Printexc.record_backtrace true;
  (* This is the only acceptable umask when building packets. Any other gives
   * wrong permissions in the packages, like 711 for /usr, and will break
   * systems. *)
  ignore (Unix.umask 0o022);
  let kind = "native_toolchain" in
  let available = parse_package_list kind in
  let packages = filter ~kind ~available ~wishes in
  prepare ~packages;
  may waitpid (build ~work_dir ~kind packages);
  ListLabels.iter [ "cross_toolchain"; "windows" ] ~f:(fun kind ->
    let packages = ListLabels.map Options.triplets ~f:(fun triplet ->
      let kind = kind ^ "-" ^ triplet in
      let available = parse_package_list kind in
      triplet, filter ~kind ~available ~wishes
    )
    in
    let l = List.fold_left (fun l c -> List.rev_append (snd c) l) [] packages in
    prepare (rev_uniq (List.sort compare l));
    let pids = ListLabels.map packages ~f:(fun (triplet, packages) ->
      let env = [| sp "TMP=/tmp/win-builds-%s" triplet |] in
      let kind = kind ^ "-" ^ triplet in
      build ~env ~work_dir ~kind packages
    )
    in
    List.iter (may waitpid) pids
  )
