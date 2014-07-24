let args = Sys.argv

let source_path = Lib.make_path_absolute_if_not (Filename.dirname args.(0))

let work_dir =
  if Array.length args < 2 then (
    Lib.log Lib.cri "Not enough arguments.\n%!";
    exit 1
  )
  else
    Lib.make_path_absolute_if_not args.(1)

let version = Sys.getenv "VERSION_DEV"

let version_short =
  try
    List.hd (Str.split (Str.regexp "-") version)
  with
  | Not_found -> version
