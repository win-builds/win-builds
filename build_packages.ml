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
    let print_callstack oc =
      Printexc.print_raw_backtrace oc (Printexc.get_callstack 100)
    in
    (if threshold >= level then Printf.kfprintf else Printf.ikfprintf)
    (if threshold >= level then print_callstack else (fun _ -> ()))
    stderr

  let sp = Printf.sprintf

  type command = {
    cmd : string;
    pid : int;
  }

  let waitpid command =
    match snd (Unix.waitpid [] command.pid) with
    | Unix.WEXITED i ->
        if i <> 0 then
          log err "Command `%s' returned %d.\n%!" command.cmd i
    | Unix.WSIGNALED i ->
        log err "Command `%s' has been signaled with signal %d.\n%!" command.cmd i
    | Unix.WSTOPPED i ->
        log err "Command `%s' has been stopped with signal %d.\n%!" command.cmd i

  let add_to_current_environment = function
    | None -> Unix.environment ()
    | Some env -> Array.concat [ env; Unix.environment () ]

  let create_process_sync ?(stdout=Unix.stdout) ?(stderr=Unix.stderr) ?env a =
    let cmd = String.concat " " (Array.to_list a) in
    log dbg "Going to run and wait for `%s'.\n%!" cmd;
    let env = add_to_current_environment env in
    let pid = Unix.create_process_env a.(0) a env Unix.stdin stdout stderr in
    waitpid { pid = pid; cmd = cmd }

  let create_process_async ?(stdout=Unix.stdout) ?(stderr=Unix.stderr) ?env a =
    let cmd = String.concat " " (Array.to_list a) in
    log dbg "Going to run `%s'.\n%!" cmd;
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

  let queue_to_list q =
    List.rev (Queue.fold (fun l e -> e :: l) [] q)
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
        Lib.log Lib.wrn "Warning. Going to build everything. This will take a while.\n";
        Lib.log Lib.wrn "You have 10 seconds to cancel.\n%!";
        Unix.sleep 10
      );
      []
    )
    else
      Array.to_list (Array.sub args 3 (Array.length args - 3))
end

open Lib
open Options
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

let build ~work_dir ~kind ~available ~wishes ?env () =
  let packages = filter ~kind ~available ~wishes in
  if packages <> [] then (
    log dbg "Building: %s.\n%!"
      (String.concat ", " (List.map (fun p -> p.name) packages));
    create_process_sync [| "mkdir"; "-p"; work_dir |];
    ListLabels.iter packages ~f:(fun p ->
      create_process_sync [|
        "tar"; "cf"; sp "%s/%s.tar" work_dir p.name;
        sp "--transform=s/config-%s/config/" (default ~default:"" p.variant);
        sp "--transform=s/%s.SlackBuild/%s.SlackBuild/" p.package p.name;
        "-C"; Filename.concat p.dir p.package; "."
      |]
    );
    if chroot then
      assert false
    else (
      let bd_files = [| "build_daemon"; "build_daemon_config" |] in
      let bd_files = Array.map (Filename.concat source_path) bd_files in
      cp ~dest:work_dir ~sources:bd_files;
      Some (create_process_async ?env (Array.concat [
        [| Filename.concat work_dir "build_daemon"; kind |];
        Array.map (fun p -> p.name) (Array.of_list packages)
      ]))
    )
  )
  else
    None

let sbo = "slackbuilds.org"
let slack d = Filename.concat "slackware64-current" d
let mingw = "mingw"

let add_package q =
  fun ?variant ~dir package ->
    Queue.push {
      dir = dir;
      package = package;
      variant = variant;
      name = (match variant with None -> package | Some variant -> sp "%s-%s" package variant)
    } q

let native_toolchain =
  let name = "native_toolchain" in
  let q = Queue.create () in
  let f = add_package q in
  f ~dir:sbo "ocaml";
  f ~dir:sbo "lua";
  f ~dir:sbo "eina";
  f ~dir:sbo "eet";
  f ~dir:sbo "evas";
  f ~dir:sbo "ecore";
  f ~dir:sbo "embryo";
  f ~dir:sbo "edje";
  name, queue_to_list q

let cross_toolchain ~triplet =
  let name = sp "cross_toolchain-%s" triplet in
  let q = Queue.create () in
  let f = add_package q in
  f ~dir:(slack "d") "binutils";
  f ~dir:mingw ~variant:"headers" "mingw-w64";
  f ~dir:(slack "d") ~variant:"core" "gcc";
  f ~dir:mingw ~variant:"full" "mingw-w64";
  f ~dir:(slack "d") ~variant:"full" "gcc";
  f ~dir:mingw "flexdll";
  if triplet = "i686-w64-mingw32" then (
    f ~dir:sbo "ocaml";
    f ~dir:sbo "ocaml-findlib";
  );
  name, queue_to_list q

let windows ~triplet =
  let name = sp "windows-%s" triplet in
  let q = Queue.create () in
  let f = add_package q in
  f ~dir:(slack "l") ~variant:"yypkg" "libarchive";
  f ~dir:(slack "n") ~variant:"yypkg" "wget";
  f ~dir:mingw "winpthreads";
  f ~dir:mingw "win-iconv";
  f ~dir:(slack "a") "gettext";
  f ~dir:(slack "a") "xz";
  f ~dir:(slack "l") "zlib";
  f ~dir:(slack "l") "libjpeg";
  f ~dir:(slack "l") "expat";
  f ~dir:(slack "l") "libpng";
  f ~dir:(slack "l") "freetype";
  f ~dir:(slack "x") "fontconfig"; (* depends on expat, freetype *)
  f ~dir:(slack "l") "giflib";
  f ~dir:(slack "l") "libtiff";
  f ~dir:sbo "lua";
  f ~dir:(slack "n") "ca-certificates";
  f ~dir:(slack "n") "openssl";
  f ~dir:(slack "l") "gmp";
  f ~dir:(slack "n") "nettle";
  f ~dir:(slack "n") "gnutls";
  f ~dir:(slack "n") "curl";
  f ~dir:sbo "c-ares";
  f ~dir:mingw "pixman";
  f ~dir:(slack "l") "libffi";
  f ~dir:(slack "l") "glib2";
  f ~dir:(slack "l") "cairo";
  f ~dir:(slack "l") "atk";
  f ~dir:(slack "l") "pango";
  f ~dir:(slack "l") "gdk-pixbuf2";
  (* GTK+2 simply doesn't work for x86_64-w64-mingw32 *)
  if triplet = "i686-w64-mingw32" then (
    f ~dir:(slack "l") "gtk+2"
  );
  f ~dir:(slack "l") "glib-networking";
  f ~dir:(slack "l") "libxml2";
  f ~dir:(slack "ap") "sqlite";
  f ~dir:(slack "l") "libsoup";
  f ~dir:(slack "l") "icu4c";
  f ~dir:(slack "d") "gperf";
  (* f ~dir:(slack "l") "libxslt"; *)
  f ~dir:(slack "l") "mpfr";
  f ~dir:(slack "l") "libmpc";
  f ~dir:(slack "l") "libogg";
  f ~dir:(slack "l") "libvorbis";
  f ~dir:(slack "l") "libtheora";
  List.iter (f ~dir:sbo)
    [ "evil"; "eina"; "eet"; "evas"; "ecore"; "edje"; "elementary" ];
  f ~dir:(slack "d") "pkg-config";
  f ~dir:(slack "l") ~variant:"full" "libarchive";
  f ~dir:(slack "n") ~variant:"full" "wget";
  f ~dir:mingw ~variant:"full" "mingw-w64";
  f ~dir:(slack "d") "binutils";
  f ~dir:(slack "d") ~variant:"full" "gcc";
  f ~dir:sbo "x264";
  (* f ~dir:(slack "a") "file"; *)
  (* f ~dir:sbo/ffmpeg; *)
  (* f ~dir:(slack "l") "sdl" "base"; *)
  (* f ~dir:(slack "l") "sdl" "image"; *)
  (* f ~dir:(slack "l") "sdl" "mixer"; *)
  (* f ~dir:(slack "l") "sdl" "net"; *)
  (* f ~dir:(slack "l") "sdl" "ttf"; *)
  f ~dir:(slack "a") "dbus";
  (* f ~dir:(slack "l") "dbus-glib"; *)
  (* f ~dir:sbo/webkit-gtk; *)
  (* f ~dir:slack/xap/gucharmap; (* requires GTK+-3 *) *)
  (* f ~dir:slack/xap/geeqie; (* includes <pwd.h> *) *)
  (* f ~dir:sbo/luajit; *)
  name, queue_to_list q


let () =
  Printexc.record_backtrace true;
  (* This is the only acceptable umask when building packets. Any other gives
   * wrong permissions in the packages, like 711 for /usr, and will break
   * systems. *)
  ignore (Unix.umask 0o022);
  let kind, available = native_toolchain in
  may waitpid (build ~work_dir ~kind ~available ~wishes ());
  let pids = ListLabels.map triplets ~f:(fun triplet ->
    let env = [| sp "TMP=/tmp/win-builds-%s" triplet |] in
    let kind, available = cross_toolchain ~triplet in
    build ~env ~work_dir ~kind ~available ~wishes ()
  )
  in
  List.iter (may waitpid) pids
