let builder ~name ~target =
  let open Config in
  let build = Arch.slackware in (* XXX *)
  (* TODO *)
  let host = Arch.slackware in (* XXX *)
  let prefix = Prefix.t ~build ~host ~target in
  let logs, yyoutput = Package.logs_yyoutput ~nickname:prefix.Prefix.nickname in
  let open Arch in
  let open Prefix in
  let open Package in
  let open Builder in
  {
    name;
    prefix; logs; yyoutput;
    path = Env.Prepend [ bindir prefix; bindir Native_toolchain.builder.prefix ];
    (* FIXME: this should also include native_prefix *)
    pkg_config_path = Env.Prepend [ Filename.concat prefix.libdir "pkgconfig" ];
    pkg_config_libdir = Env.Keep;
    tmp = Env.Set [ Filename.concat prefix.yyprefix "tmp" ];
    target_prefix = None; (* updated from the Windows module *)
    cross_prefix  = None;
    native_prefix = Some Native_toolchain.builder.prefix.yyprefix;
    packages = [];
    redistributed = false;
  }

let do_adds builder =
  let open Sources in
  let add_full = Worker.register ~builder in
  let add = add_full ?outputs:None in

#use "slackware64-current/d/binutils/wb.ml"
#use "mingw/mingw-w64/wb:headers.ml"
#use "slackware64-current/d/gcc/wb:core.ml"
#use "mingw/mingw-w64/wb:full.ml"
  let winpthreads = mingw_w64_add ("winpthreads", None)
    ~dependencies:[ binutils; gcc_core; mingw_w64_full ]
    ~build:2
  in
#use "slackware64-current/d/gcc/wb:full.ml"
#use "mingw/gendef/wb.ml"
#use "mingw/genidl/wb.ml"
#use "mingw/genpeimg/wb.ml"
#use "mingw/widl/wb.ml"
#use "mingw/flexdll/wb.ml"
#use "slackbuilds.org/ocaml/ocaml/wb.ml"
  let ocaml = ocaml_add
    ~dependencies:[ binutils; flexdll; gcc_full; mingw_w64_full ]
  in

#use "slackbuilds.org/ocaml/ocaml-findlib/wb.ml"
#use "mingw/zz_config/wb.ml"

#extras

  let _all = add_full ("all", None)
    ~dir:""
    ~dependencies:[
      gcc_full; mingw_w64_full; binutils; mingw_w64_full;
      gendef; genidl; genpeimg; widl; zz_config
    ]
    ~version:"0.0.0"
    ~build:1
    ~sources:[]
    ~outputs:[]
  in

  let _yypkg = add_full ("yypkg", None)
    ~dir:""
    ~dependencies:[ flexdll; ocaml; ocaml_findlib ]
    ~version:"1.0.0"
    ~build:1
    ~sources:[]
    ~outputs:[]
  in

  ()

let builder_32 =
  builder ~name:"cross_toolchain_32" ~target:Config.Arch.windows_32
let builder_64 =
  builder ~name:"cross_toolchain_64" ~target:Config.Arch.windows_64

let () =
  do_adds builder_32;
  do_adds builder_64
