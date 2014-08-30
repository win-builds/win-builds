let builder =
  let open Config in
  let build = Arch.slackware in (* XXX *)
  let host = Arch.slackware in (* XXX *)
  let target = Arch.slackware in (* XXX *)
  let prefix = Prefix.t ~build ~host ~target in
  let logs, yyoutput = Builder.logs_yyoutput ~nickname:prefix.Prefix.nickname in
  let open Arch in
  let open Prefix in
  let open Builder in
  {
    name = "native_toolchain";
    prefix; logs; yyoutput;
    path = Env.Prepend [ bindir prefix ];
    pkg_config_path = Env.Prepend [ Filename.concat prefix.libdir "pkgconfig" ];
    pkg_config_libdir = Env.Keep;
    tmp = Env.Set [ Filename.concat prefix.Prefix.yyprefix "tmp" ];
    target_prefix = None;
    cross_prefix  = None;
    native_prefix = None;
    packages = [];
  }

let add_full =
  Config.Builder.register ~builder

let add = add_full ?outputs:None

let ocaml = add ("ocaml", None)
  ~dir:"slackbuilds.org/ocaml"
  ~dependencies:[]
  ~version:"4.01.0-trunk"
  ~build:2
  ~sources:[
    "${PACKAGE}-${VERSION}.tar.gz", "8996881034bec1c222ed91259238ea151b42a11d";
  ]

let lua = add ("lua", None)
  ~dir:"slackbuilds.org/development"
  ~dependencies:[]
  ~version:"5.1.5"
  ~build:1
  ~sources:[
    "${PACKAGE}-${VERSION}.tar.gz", "b3882111ad02ecc6b972f8c1241647905cb2e3fc";
    "${PACKAGE}.pc", "";
    "src_makefile", "";
  ]

let efl = add ("efl", Some "for-your-tools-only")
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[ lua ]
  ~version:"1.11.0-beta1"
  ~build:1
  ~sources:[
    "${PACKAGE}-${VERSION}.tar.xz", "485b8cdd9eb4b7c0cfa0a1e5208b94043fd21bf7";
  ]

let elementary = add ("elementary", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[ efl ]
  ~version:"1.11.0-beta1"
  ~build:1
  ~sources:[
    "${PACKAGE}-${VERSION}.tar.xz", "f182ed80fda417cbd2c15a0b25fbf2d9d3652ca8";
  ]

let qt = add ("qt", Some "native")
  ~dir:"slackware64-current/l"
  ~dependencies:[]
  ~version:"5.3.1"
  ~build:1
  ~sources:[
    "qt-everywhere-opensource-src-${VERSION}.tar.gz", "3244dd34f5fb695e903eaa49c6bd0838b9bf7a73";
    "Qt.pc", "";
    "0001-configure-use-pkg-config-for-libpng.patch", "";
    "0001-windployqt-Fix-cross-compilation.patch", "";
    "0002-Use-widl-instead-of-midl.-Also-set-QMAKE_DLLTOOL-to-.patch", "";
    "0003-Tell-qmake-to-use-pkg-config.patch", "";
    "qt.fix.broken.gif.crash.diff.gz", "";
    "qt.mysql.h.diff.gz", "";
    "qt.webkit-no_Werror.patch.gz", "";
    "qt.yypkg.script", "";
    "qt5-dont-add-resource-files-to-qmake-libs.patch", "";
    "qt5-dont-build-host-libs-static.patch", "";
    "qt5-qmake-implib-dll-a.patch", "";
    "qt5-use-system-zlib-in-host-libs.patch", "";
    "qt5-workaround-qtbug-29426.patch", "";
  ]

let _all = add ("all", None)
  ~dir:""
  ~dependencies:[ lua; qt; efl; elementary ]
  ~version:"0.0.0"
  ~build:1
  ~sources:[]
