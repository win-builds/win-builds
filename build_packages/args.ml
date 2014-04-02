let args = Sys.argv

let source_path = Lib.make_path_absolute_if_not (Filename.dirname args.(0))

let work_dir =
  if Array.length args < 2 then (
    Lib.log Lib.cri "Not enough arguments.\n%!";
    exit 1
  )
  else
    Lib.make_path_absolute_if_not args.(1)

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
      (* Unix.sleep 10 *)
      Unix.sleep 1
    );
    []
  )
  else
    Array.to_list (Array.sub args 3 (Array.length args - 3))
