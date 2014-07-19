open Types
open Config
open Lib

(* module Windows_32 = Windows_32
module Windows_64 = Windows_64 *)
module Cross_toolchain_32 = Cross_toolchain_32
(* module Cross_toolchain_64 = Cross_toolchain_64
module Native_toolchain = Native_toolchain *)

module B = struct
  let needs_rebuild ~sources ~outputs =
    let mod_time prev file =
      max prev (Unix.lstat file).Unix.st_mtime
    in
    (List.fold_left mod_time 0. sources) > (List.fold_left mod_time 0. outputs)

  let hash_file file =
    let fd = Unix.openfile file [ Unix.O_RDWR ] 0o644 in
    let ba = Bigarray.(Array1.map_file fd char c_layout false (-1)) in
    let h = Hashtbl.hash ba in
    Unix.close fd;
    h

  let build_one builder =
    run [| "mkdir"; "-p"; builder.Builder.yyoutput; builder.Builder.logs |];
    let env = Builder.env builder in
    (if not (Sys.file_exists builder.Builder.prefix.Prefix.yyprefix)
      || Sys.readdir builder.Builder.prefix.Prefix.yyprefix = [| |] then
      run [| "yypkg"; "--init"; "--prefix"; builder.Builder.prefix.Prefix.yyprefix |]);
    fun p ->
      let yyoutputize = Filename.concat builder.Builder.yyoutput in
      let outputs = (List.map yyoutputize p.outputs) in
      let sources = (List.map yyoutputize p.sources) in
      if not (needs_rebuild ~sources ~outputs) then
        ()
      else
        progress "[%s] Building %s.\n%!" builder.Builder.prefix.Prefix.nickname (name p);
        let dir = Filename.concat p.dir p.package in
        let variant_suffix = match p.variant with None -> "" | Some s -> "-" ^ s in
        let log =
          let filename = Filename.concat builder.Builder.logs (name p) in
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
            sp "if [ -e config%s ]; then . ./config%s; fi" variant_suffix variant_suffix;
            sp "exec bash -x %s.SlackBuild" p.package
          ]
        |];
        run (Array.of_list ("yypkg" :: "--upgrade" :: "--install-new" :: outputs));
        Unix.close log
end

let build builder =
  let packages =
    List.assoc builder.Builder.prefix.Prefix.nickname !Package_list.lists
    |> list_of_queue
    |> List.filter (fun p -> p.to_build)
    (* |> sort_by_dependencies *)
  in
  (if packages <> [] then (
    progress "[%s] " builder.Builder.prefix.Prefix.nickname;
    progress "Building: %s.\n%!" (String.concat ", " (List.map name packages));
    (* TODO: propagate failures *)
    List.iter (B.build_one builder) packages;
  ));
  progress "[%s] Setting up repository.\n%!" builder.Builder.prefix.Prefix.nickname;
  try (* XXX: this won't raise an exception I think *)
    run [| "yypkg"; "--repository"; "--generate"; builder.Builder.yyoutput |]
  with _ -> Printf.eprintf "ERROR: Couldn't create repository!\n%!"

let build_parallel builders =
  List.iter Thread.join (List.map (Thread.create build) builders)

let () =
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
