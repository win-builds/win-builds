let builder =
  let open Config in
  let build = Arch.slackware in (* XXX *)
  let host = Arch.slackware in (* XXX *)
  let target = Arch.slackware in (* XXX *)
  let prefix = Prefix.t ~build ~host ~target in
  let logs, yyoutput = Package.logs_yyoutput ~nickname:prefix.Prefix.nickname in
  let open Arch in
  let open Prefix in
  let open Package in
  let open Builder in
  {
    name = "native_toolchain";
    prefix; logs; yyoutput;
    path = Env.Prepend [ bindir prefix ];
    pkg_config_path = Env.Prepend [ Filename.concat prefix.libdir "pkgconfig" ];
    pkg_config_libdir = Env.Keep;
    tmp = Env.Set [ Filename.concat prefix.yyprefix "tmp" ];
    target_prefix = None;
    cross_prefix  = None;
    native_prefix = None;
    packages = [];
    redistributed = false;
  }

let add_full =
  Worker.register ~builder

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

  let _all = add_full ("all", None)
    ~dir:""
    ~dependencies:[ autoconf; automake; libtool; lua; qt; efl; elementary ]
    ~version:"0.0.0"
    ~build:1
    ~sources:[]
    ~outputs:[]
  in

  ignore [ ocaml ]
