let add =
  Package_list.register ~name:"cross_toolchain_32"

let add_ocaml =
  Package_list.register ~name:"cross_toolchain_32_ocaml"

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
  ~outputs:[
    "binutils-${VERSION}-${BUILD}-${TARGET_TRIPLET}-${HOST_TRIPLET}.txz";
  ]

let mingw_w64_add = add
  ~dir:"mingw"
  ~version:"3.1.0"
  ~build:1
  ~sources:[
    "mingw-w64-v${VERSION}.tar.bz2"
  ]
  ~outputs:[
    "mingw-w64-${VERSION}-${BUILD}-${TARGET_TRIPLET}-${HOST_TRIPLET}.txz";
  ]

let gcc_add = add
  ~dir:"slackware64-current/d"
  ~version:"4.8.2"
  ~build:1
  ~sources:[
    "gcc-v${VERSION}.tar.xz"
  ]
  ~outputs:[
    "gcc-${VERSION}-${BUILD}-${TARGET_TRIPLET}-${HOST_TRIPLET}.txz";
  ]

let mingw_w64_headers = mingw_w64_add ("mingw-w64", Some "headers")
  ~dependencies:[]

let gcc_core = gcc_add ("gcc", Some "core")
  ~dependencies:[ mingw_w64_headers ]

let mingw_w64_full = mingw_w64_add ("mingw-w64", Some "full")
  ~dependencies:[ gcc_core ]

let winpthreads = add ("winpthreads", None)
  ~dir:"mingw"
  ~dependencies:[ gcc_core; mingw_w64_full ]
  ~version:"3.1.0"
  ~build:1
  ~sources:[
    "winpthreads-v${VERSION}.tar.bz2"
  ]
  ~outputs:[
    "winpthreads-${VERSION}-${BUILD}-${TARGET_TRIPLET}-${HOST_TRIPLET}.txz";
  ]

let gcc_full = gcc_add ("gcc", Some "full")
  ~dependencies:[ gcc_core; mingw_w64_full; winpthreads ]

(* let widl = add ("widl", None)
  ~dir:"mingw"
  ~dependencies:[]
  ~version:"3.1.0"
  ~build:1
  ~sources:[
    "winpthreads-v${version}.tar.bz2"
  ]
  ~outputs:[
    "winpthreads-${VERSION}-${BUILD}-${Target_triplet}-${HOST_TRIPLET}.txz";
  ]

let flexdll = add ("flexdll", None)
  ~dir:"mingw"
  ~dependencies:[]

let ocaml = add_ocaml ("ocaml", None)
  ~dir:"slackbuilds.org"
  ~dependencies:[]

let ocaml_findlib = add_ocaml ("ocaml-findlib", None)
  ~dir:"slackbuilds.org"
  ~dependencies:[]
*)
