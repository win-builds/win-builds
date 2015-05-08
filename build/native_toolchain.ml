let add_full =
  Worker.register ~builder:Builders.Native_toolchain.builder

let add = add_full ?outputs:None

let _ =
  let open Sources in
#use "slackware64-current/d/autoconf/wb.ml"
#use "slackware64-current/d/libtool/wb.ml"
#use "slackware64-current/d/automake/wb.ml"
#use "slackbuilds.org/ocaml/ocaml/wb.ml"
  let ocaml = ocaml_add ~dependencies:[] in
#use "slackbuilds.org/development/lua/wb.ml"
#use "slackbuilds.org/libraries/efl/wb:for-your-tools-only.ml"
#use "slackbuilds.org/libraries/elementary/wb:regular.ml"
#use "slackware64-current/l/qt/wb:native.ml"

#extras

  let _all = add_full ("all", None)
    ~dir:""
    ~dependencies:[ autoconf; automake; libtool; lua; qt; efl; elementary ]
    ~version:"0.0.0"
    ~build:1
    ~sources:[]
    ~outputs:[]
  in

  ignore [ ocaml ]
