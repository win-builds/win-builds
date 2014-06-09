let add =
  Package_list.register ~name:"cross_toolchain_64"

let binutils = add ("binutils", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]

let mingw_w64_headers = add ("mingw-w64", Some "headers")
  ~dir:"mingw"
  ~dependencies:[]

let gcc_core = add ("gcc", Some "core")
  ~dir:"slackware64-current/d"
  ~dependencies:[]

let mingw_w64_full = add ("mingw-w64", Some "full")
  ~dir:"mingw"
  ~dependencies:[]

let winpthreads = add ("winpthreads", None)
  ~dir:"mingw"
  ~dependencies:[]

let gcc_full = add ("gcc", Some "full")
  ~dir:"slackware64-current/d"
  ~dependencies:[]

let widl = add ("widl", None)
  ~dir:"mingw"
  ~dependencies:[]

(* let flexdll = add ("flexdll", None)
  ~dir:"# mingw"
  ~dependencies:[] *)

