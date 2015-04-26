let re_use = Str.regexp "[ ]*#use \"\\(.*\\)\""
let re_variant = Str.regexp "\\(.*\\):\\(.*\\)"

let rec use ?(with_module = false) file =
  let lines = ref 0 in
  let basename = Filename.chop_extension (Filename.basename file) in
  let ic = open_in_bin file in
  (if with_module then (
    let modname = String.capitalize basename in
    Printf.printf "module %s = struct\n" (String.capitalize modname)
  )
  else (
    Printf.printf "# 1 \"%s [header]\"\n" file;
    Printf.printf "let dir = %S in\n" (Filename.dirname file);
    if Str.string_match re_variant basename 0 then (
      Printf.printf "let name = %S in\n" (Str.matched_group 1 basename);
      Printf.printf "let variant = Some %S in\n" (Str.matched_group 2 basename);
    )
    else (
      Printf.printf "let name = %S in\n" basename;
      Printf.printf "let variant = None in\n";
    )
  ));
  Printf.printf "# 1 %S\n" file;
  (try
    while true do
       let s = input_line ic in
       incr lines;
       if Str.string_match re_use s 0 then (
         let file' = Str.matched_group 1 s in
         use ~with_module:false file';
         Printf.printf "# %d %S\n" !lines file;
       )
       else (
         Printf.printf "%s\n" s
       )
     done
  with End_of_file -> ());
  (if with_module then
    Printf.printf "end\n");
  close_in ic
;;

use ~with_module:true "win-builds/build/lib.ml";;
use ~with_module:true "win-builds/build/config.ml";;
use ~with_module:true "win-builds/build/sources.ml";;
use ~with_module:true "win-builds/build/worker.ml";;
use ~with_module:true "win-builds/build/native_toolchain.ml";;
use ~with_module:true "win-builds/build/cross_toolchain.ml";;
use ~with_module:true "win-builds/build/windows.ml";;
use ~with_module:true "win-builds/build/build.ml";;

