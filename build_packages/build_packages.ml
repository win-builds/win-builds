open Types
open Config
open Lib

module B = struct
  module S = Set.Make (struct
    type t = string * int
    let compare = compare
  end)

  let diff ~pre ~post =
    let a_to_s a = Array.fold_left (fun s e -> S.add e s) S.empty a in
    List.map fst (S.elements (S.diff (a_to_s post) (a_to_s pre)))

  let hash_file file =
    let fd = Unix.openfile file [ Unix.O_RDWR ] 0o644 in
    let ba = Bigarray.(Array1.map_file fd char c_layout false (-1)) in
    let h = Hashtbl.hash ba in
    Unix.close fd;
    h

  let build_one builder =
    let list_yyoutput () =
      let d = builder.Builder.yyoutput in
      let a = Sys.readdir d in
      let lapin f =
        let f = Filename.concat d f in
        f, hash_file f
      in
      Array.map lapin a
    in
    run [| "mkdir"; "-p"; builder.Builder.yyoutput; builder.Builder.logs |];
    let env = Builder.env builder in
    (if not (Sys.file_exists builder.Builder.prefix.Prefix.yyprefix) then
      run [| "yypkg"; "--init"; "--prefix"; builder.Builder.prefix.Prefix.yyprefix |]);
    fun p ->
      progress "[%s] Building %s.\n%!" builder.Builder.prefix.Prefix.nickname p.name;
      let dir = Filename.concat p.dir p.package in
      let variant_suffix = match p.variant with None -> "" | Some s -> "-" ^ s in
      let log = Unix.openfile (Filename.concat builder.Builder.logs p.name) [ Unix.O_RDWR; Unix.O_CREAT; Unix.O_TRUNC ] 0o644 in
      let run a = run ~stdout:log ~stderr:log ~env a in
      let pre = list_yyoutput () in
      run [|
        "sh"; "-cex";
        String.concat "; " [
          sp "cd %S" dir;
          sp "export DESCR=\"$(sed -n 's;^[-[:alnum:]]\\+: ;; p' slack-desc | sed -e 's;\";\\\\\\\\\";g' -e 's;/;\\\\/;g' | tr '\\n' ' ')\"";
          sp "export PREFIX=\"$(echo \"${YYPREFIX}\" | sed 's;^/;;')\"";
          sp "if [ -e config%s ]; then source ./config%s; fi" variant_suffix variant_suffix;
          sp "exec bash -x %s.SlackBuild" p.package
        ]
      |];
      let post = list_yyoutput () in
      let to_install = diff ~pre ~post in
      run (Array.of_list ("yypkg" :: "--upgrade" :: "--install-new" :: to_install));
      Unix.close log
end

let parse_package_list builder =
  let name = builder.Builder.prefix.Prefix.nickname in
  let package_list = filename_concat [Args.source_path; "package_list"; name] in
  let ic = open_in_bin package_list in
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

let build builder =
  if List.mem builder.Builder.prefix.Prefix.kind Args.kinds then (
    let packages =
      let available = parse_package_list builder in
      if Args.wishes = [] then
        available
      else
        List.filter (fun p -> List.mem p.name Args.wishes) available
    in
    progress "[%s] " builder.Builder.prefix.Prefix.nickname;
    (if packages <> [] then
      progress "Building: %s.\n%!"
        (String.concat ", " (List.map (fun p -> p.name) packages))
    else
      progress "Nothing to build\n%!");
    (* TODO: propagate failures *)
    List.iter (B.build_one builder) packages;
    progress "[%s] Setting up repository.\n%!" builder.Builder.prefix.Prefix.nickname
  )
  else
    ()

let build_parallel builders =
  List.iter Thread.join (List.map (Thread.create build) builders)

let () =
  Printexc.record_backtrace true;
  (* This is the only acceptable umask when building packets. Any other gives
   * wrong permissions in the packages, like 711 for /usr, and will break
   * systems. *)
  ignore (Unix.umask 0o022);
  let cross_32 = Builder.cross Arch.windows_32 in
  let cross_64 = Builder.cross Arch.windows_64 in
  let windows_32 = Builder.windows ~cross:cross_32 Arch.windows_32 in
  let windows_64 = Builder.windows ~cross:cross_64 Arch.windows_64 in
  build Builder.native;
  build_parallel [ cross_32; cross_64 ];
  build_parallel [ windows_32; windows_64 ]
