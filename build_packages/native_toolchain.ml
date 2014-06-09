let add =
  Package_list.register ~name:"native_toolchain"

let add_ocaml =
  Package_list.register ~name:"native_toolchain_ocaml"

let ocaml = add_ocaml ("ocaml", None)
  ~dir:"slackbuilds.org"
  ~dependencies:[]

let lua = add ("lua", None)
  ~dir:"slackbuilds.org/development"
  ~dependencies:[]

let efl = add ("efl", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

let elementary = add ("elementary", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

