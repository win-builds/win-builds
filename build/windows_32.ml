let add =
  Package_list.register ~name:"windows_32"

let add_yypkg =
  Package_list.register ~name:"yypkg"

let xz_yypkg = add_yypkg ("xz", Some "yypkg")
  ~dir:"slackware64-current/a"
  ~dependencies:[]

let libarchive_yypkg = add_yypkg ("libarchive", Some "yypkg")
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let winpthreads = add ("winpthreads", None)
  ~dir:"mingw"
  ~dependencies:[]

let widl = add ("widl", None)
  ~dir:"mingw"
  ~dependencies:[]

let win_iconv = add ("win-iconv", None)
  ~dir:"mingw"
  ~dependencies:[]

let gettext = add ("gettext", None)
  ~dir:"slackware64-current/a"
  ~dependencies:[]

let xz = add ("xz", Some "regular")
  ~dir:"slackware64-current/a"
  ~dependencies:[]

let zlib = add ("zlib", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libjpeg = add ("libjpeg", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let expat = add ("expat", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libpng = add ("libpng", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let freetype = add ("freetype", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let fontconfig = add ("fontconfig", None)
  ~dir:"slackware64-current/x"
  ~dependencies:[ freetype; expat ]

let giflib = add ("giflib", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libtiff = add ("libtiff", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let lua = add ("lua", None)
  ~dir:"slackbuilds.org/development"
  ~dependencies:[]

let ca_certificates = add ("ca-certificates", None)
  ~dir:"slackware64-current/n"
  ~dependencies:[]

let openssl = add ("openssl", None)
  ~dir:"slackware64-current/n"
  ~dependencies:[]

let gmp = add ("gmp", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let nettle = add ("nettle", None)
  ~dir:"slackware64-current/n"
  ~dependencies:[]

let libtasn1 = add ("libtasn1", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let gnutls = add ("gnutls", None)
  ~dir:"slackware64-current/n"
  ~dependencies:[]

let curl = add ("curl", None)
  ~dir:"slackware64-current/n"
  ~dependencies:[]

let c_ares = add ("c-ares", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

let pixman = add ("pixman", None)
  ~dir:"mingw"
  ~dependencies:[]

let libffi = add ("libffi", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let glib2 = add ("glib2", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let cairo = add ("cairo", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let atk = add ("atk", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let pango = add ("pango", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let gdk_pixbuf2 = add ("gdk-pixbuf2", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let gtk_2 = add ("gtk+2", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let glib_networking = add ("glib-networking", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libxml2 = add ("libxml2", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let sqlite = add ("sqlite", None)
  ~dir:"slackware64-current/ap"
  ~dependencies:[]

let libsoup = add ("libsoup", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let icu4c = add ("icu4c", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let gperf = add ("gperf", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]

(* let libxslt = add ("libxslt", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[] *)

let mpfr = add ("mpfr", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libmpc = add ("libmpc", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libogg = add ("libogg", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libvorbis = add ("libvorbis", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libtheora = add ("libtheora", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let fribidi = add ("fribidi", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libsndfile = add ("libsndfile", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let dbus = add ("dbus", None)
  ~dir:"slackware64-current/a"
  ~dependencies:[]

let harfbuzz = add ("harfbuzz", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let efl = add ("efl", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

let elementary = add ("elementary", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

let pkg_config = add ("pkg-config", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]

let libarchive = add ("libarchive", Some "regular")
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let wget = add ("wget", None)
  ~dir:"slackware64-current/n"
  ~dependencies:[]

let mingw_w64 = add ("mingw-w64", Some "full")
  ~dir:"mingw"
  ~dependencies:[]

let binutils = add ("binutils", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]

let gcc = add ("gcc", Some "full")
  ~dir:"slackware64-current/d"
  ~dependencies:[]

let x264 = add ("x264", None)
  ~dir:"slackbuilds.org/multimedia"
  ~dependencies:[]

let pcre = add ("pcre", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let flac = add ("flac", None)
  ~dir:"slackware64-current/ap"
  ~dependencies:[]

(* let cdparanoia = add ("cdparanoia", None)
  ~dir:"slackware64-current/ap"
  ~dependencies:[] *)

let gdb = add ("gdb", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]

let libao = add ("libao", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

(* requires ddk *)
(* let libcdio = add ("libcdio", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[] *)

(* let libdvdread = add ("libdvdread", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[] *)

(* let libidn = add ("libidn", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[] *)

let libmad = add ("libmad", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let libid3tag = add ("libid3tag", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let madplay = add ("madplay", None)
  ~dir:"slackware64-current/ap"
  ~dependencies:[]

let lcms = add ("lcms", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let lcms2 = add ("lcms2", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let djvulibre = add ("djvulibre", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

let dejavu_fonts_ttf = add ("dejavu-fonts-ttf", None)
  ~dir:"slackware64-current/x"
  ~dependencies:[]

let speex = add ("speex", None)
  ~dir:"slackbuilds.org/audio"
  ~dependencies:[]

let opus = add ("opus", None)
  ~dir:"slackbuilds.org/audio"
  ~dependencies:[]

let a52dec = add ("a52dec", None)
  ~dir:"slackbuilds.org/audio"
  ~dependencies:[]

let libmpeg2 = add ("libmpeg2", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

let libsigc_plus_plus = add ("libsigc++", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

let jansson = add ("jansson", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]

(* let libcddb = add ("libcddb", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[] *)

let qt = add ("qt", None)
  ~dir:"slackware64-current/l"
  ~dependencies:[]

(*
let file = add ("file", None)
  ~dir:"slackware64-current/a"
  ~dependencies:[]

let ffmpeg = add ("ffmpeg", None)
  ~dir:"slackbuilds.org/multimedia"
  ~dependencies:[]

let sdl:base = add ("sdl:base", None)
  ~dir:"# slackware64-current/l"
  ~dependencies:[]

let sdl:image = add ("sdl:image", None)
  ~dir:"# slackware64-current/l"
  ~dependencies:[]

let sdl:mixer = add ("sdl:mixer", None)
  ~dir:"# slackware64-current/l"
  ~dependencies:[]

let sdl:net = add ("sdl:net", None)
  ~dir:"# slackware64-current/l"
  ~dependencies:[]

let sdl:ttf = add ("sdl:ttf", None)
  ~dir:"# slackware64-current/l"
  ~dependencies:[]

let dbus-glib = add ("dbus-glib", None)
  ~dir:"# slackware64-current/l"
  ~dependencies:[]

let webkitgtk = add ("webkitgtk", None)
  ~dir:"# slackbuilds.org/libraries"
  ~dependencies:[]

(* requires GTK+-3" *)
let gucharmap = add ("gucharmap", None)
  ~dir:"slackware64-current/xap"
  ~dependencies:[]

(* includes <pwd.h>" *)
let geeqie = add ("geeqie", None)
  ~dir:"slackware64-current/xap"
  ~dependencies:[]

let luajit = add ("luajit", None)
  ~dir:"slackbuilds.org/development"
  ~dependencies:[]
*)

let zz_config = add ("zz_config", None)
  ~dir:"mingw"
  ~dependencies:[]

