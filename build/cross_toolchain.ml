let builder ~name ~target =
  let open Config in
  let build = Arch.slackware in (* XXX *)
  let host = Arch.slackware in (* XXX *)
  let prefix = Prefix.t ~build ~host ~target in
  let logs, yyoutput = Builder.logs_yyoutput ~nickname:prefix.Prefix.nickname in
  let open Arch in
  let open Prefix in
  let open Builder in
  {
    name;
    prefix; logs; yyoutput;
    path = Env.Prepend [ bindir prefix; bindir Native_toolchain.builder.prefix ];
    pkg_config_path = Env.Prepend [ Filename.concat prefix.libdir "pkgconfig" ];
    pkg_config_libdir = Env.Keep;
    tmp = Env.Set [ Filename.concat prefix.Prefix.yyprefix "tmp" ];
    target_prefix = None; native_prefix = None;
    packages = [];
  }

let do_adds builder =
  let add_full = Config.Builder.register ~builder in
  let add = add_full ?outputs:None in

  let binutils = add ("binutils", None)
    ~dir:"slackware64-current/d"
    ~dependencies:[]
    ~version:"2.24"
    ~build:1
    ~sources:[
      "binutils-${VERSION}.tar.gz";
      "binutils.export.demangle.h.diff.gz";
      "binutils.no-config-h-check.diff.gz";
    ]
  in

  let mingw_w64_add = add
    ~dir:"mingw"
    ~version:"v3.1.0"
    ~build:1
    ~sources:[
      "mingw-w64-${VERSION}.tar.bz2"
    ]
  in

  let gcc_add = add_full
    ~dir:"slackware64-current/d"
    ~version:"4.8.3"
    ~build:1
    ~sources:[
      "gcc-${VERSION}.tar.xz"
    ]
    ~outputs:[
      "gcc-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz";
      "gcc-g++-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz"
    ]
  in

  let mingw_w64_tool_add name = add (name, None)
    ~dir:"mingw"
    ~dependencies:[]
    ~version:"v3.1.0"
    ~build:1
    ~sources:[
      "mingw-w64-${VERSION}.tar.bz2"
    ]
  in

  let mingw_w64_headers = mingw_w64_add ("mingw-w64", Some "headers")
    ~dependencies:[]
  in

  let gcc_core = gcc_add ("gcc", Some "core")
    ~dependencies:[ binutils; mingw_w64_headers ]
  in

  let mingw_w64_full = mingw_w64_add ("mingw-w64", Some "full")
    ~dependencies:[ binutils; gcc_core ]
  in

  let winpthreads = add ("winpthreads", None)
    ~dir:"mingw"
    ~dependencies:[ binutils; gcc_core; mingw_w64_full ]
    ~version:"v3.1.0"
    ~build:1
    ~sources:[
      "mingw-w64-${VERSION}.tar.bz2"
    ]
  in

  let gcc_full = gcc_add ("gcc", Some "full")
    ~dependencies:[ binutils; gcc_core; mingw_w64_full; winpthreads ]
  in

  let gendef = mingw_w64_tool_add "gendef" in

  let genidl = mingw_w64_tool_add "genidl" in

  let genpeimg = mingw_w64_tool_add "genpeimg" in

  let widl = mingw_w64_tool_add "widl" in

  let flexdll = add ("flexdll", None)
    ~dir:"mingw"
    ~dependencies:[ binutils; gcc_full; mingw_w64_full; binutils ]
    ~version:"0.31"
    ~build:1
    ~sources:[
      "flexdll-0.31.tar.gz"
    ]
  in

  let ocaml = add ("ocaml", None)
    ~dir:"slackbuilds.org/ocaml"
    ~dependencies:[ binutils; flexdll; gcc_full; mingw_w64_full ]
    ~version:"4.01.0-trunk"
    ~build:2
    ~sources:[
      "${PACKAGE}-${VERSION}.tar.gz";
    ]
  in

  let ocaml_findlib = add ("ocaml-findlib", None)
    ~dir:"slackbuilds.org/ocaml"
    ~dependencies:[ ocaml ]
    ~version:"1.5.2"
    ~build:1
    ~sources:[
      "findlib-${VERSION}.tar.gz"
    ]
  in

  let _all = add ("all", None)
    ~dir:""
    ~dependencies:[
      gcc_full; mingw_w64_full; binutils; mingw_w64_full;
      gendef; genidl; genpeimg; widl;
    ]
    ~version:"0.0.0"
    ~build:1
    ~sources:[]
  in

  let _yypkg = add ("yypkg", None)
    ~dir:""
    ~dependencies:[ flexdll; ocaml; ocaml_findlib ]
    ~version:"1.0.0"
    ~build:1
    ~sources:[]
  in

  ()

let builder_32 =
  builder ~name:"cross_toolchain_32" ~target:Config.Arch.windows_32
let builder_64 =
  builder ~name:"cross_toolchain_64" ~target:Config.Arch.windows_64

let () =
  do_adds builder_32;
  do_adds builder_64
