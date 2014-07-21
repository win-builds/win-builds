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

let do_adds
  (add :
    (string * string option)
    -> dir:string -> dependencies : Config.Builder.package list
    -> version:string -> build:int
    -> sources: string list -> Config.Builder.package)
  =
  let binutils = add ("binutils", None)
    ~dir:"slackware64-current/d"
    ~dependencies:[]
    ~version:"2.23.2"
    ~build:1
    ~sources:[
      "binutils-${VERSION}.tar.xz";
      "binutils.export.demangle.h.diff.gz";
      "binutils.no-config-h-check.diff.gz";
    ]
  in

  let mingw_w64_add = add
    ~dir:"mingw"
    ~version:"3.1.0"
    ~build:1
    ~sources:[
      "mingw-w64-v${VERSION}.tar.bz2"
    ]
  in

  let gcc_add = add
    ~dir:"slackware64-current/d"
    ~version:"4.8.2"
    ~build:1
    ~sources:[
      "gcc-v${VERSION}.tar.xz"
    ]
  in

  let mingw_w64_headers = mingw_w64_add ("mingw-w64", Some "headers")
    ~dependencies:[]
  in

  let gcc_core = gcc_add ("gcc", Some "core")
    ~dependencies:[ mingw_w64_headers ]
  in

  let mingw_w64_full = mingw_w64_add ("mingw-w64", Some "full")
    ~dependencies:[ gcc_core ]
  in

  let winpthreads = add ("winpthreads", None)
    ~dir:"mingw"
    ~dependencies:[ gcc_core; mingw_w64_full ]
    ~version:"3.1.0"
    ~build:1
    ~sources:[
      "winpthreads-v${VERSION}.tar.bz2"
    ]
  in

  let gcc_full = gcc_add ("gcc", Some "full")
    ~dependencies:[ gcc_core; mingw_w64_full; winpthreads ]
  in

  (* let widl = add ("widl", None)
    ~dir:"mingw"
    ~dependencies:[]
    ~version:"3.1.0"
    ~build:1
    ~sources:[
      "winpthreads-v${version}.tar.bz2"
    ]
  *)

  let flexdll = add ("flexdll", None)
    ~dir:"mingw"
    ~dependencies:[ gcc_full; mingw_w64_full; binutils ]
    ~version:"0.31"
    ~build:1
    ~sources:[
      "flexdll-0.31.tar.gz"
    ]
  in

  let ocaml = add ("ocaml", None)
    ~dir:"slackbuilds.org"
    ~dependencies:[ flexdll ]
    ~version:"4.02.0"
    ~build:1
    ~sources:[]
  in

  let ocaml_findlib = add ("ocaml-findlib", None)
    ~dir:"slackbuilds.org"
    ~dependencies:[]
    ~version:"4.02.0"
    ~build:1
    ~sources:[]
  in

  let _all = add ("all", None)
    ~dir:""
    ~dependencies:[ gcc_full; mingw_w64_full; binutils; mingw_w64_full ]
    ~version:"0.0.0"
    ~build:1
    ~sources:[]
  in

  let _yypkg = add ("yypkg", None)
    ~dir:""
    ~dependencies:[ ocaml; ocaml_findlib ]
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
  do_adds (Config.Builder.register ~builder:builder_32);
  do_adds (Config.Builder.register ~builder:builder_64)
