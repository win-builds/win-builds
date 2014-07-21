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
    target_prefix = None; native_prefix = None;
    packages = [];
  }

let add =
  Config.Builder.register ~builder

let ocaml = add ("ocaml", None)
  ~dir:"slackbuilds.org"
  ~dependencies:[]
  ~version:"4.01.0"
  ~build:1
  ~sources:[ (* XXX *)
  ]

let lua = add ("lua", None)
  ~dir:"slackbuilds.org/development"
  ~dependencies:[]
  ~version:"5.1.5"
  ~build:1
  ~sources:[
    "${PACKAGE}-${VERSION}.tar.gz";
    "${PACKAGE}.pc";
    "src_makefile";
  ]

let efl = add ("efl", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]
  ~version:"1.9.2"
  ~build:1
  ~sources:[
    "${PACKAGE}-${VERSION}.tar.gz";
    "win32-fix-ecore_evas-engine-search-path.patch";
  ]

let elementary = add ("elementary", None)
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[]
  ~version:"1.9.2"
  ~build:1
  ~sources:[
    "${PACKAGE}-${VERSION}.tar.gz";
  ]

let qt = add ("qt", Some "native")
  ~dir:"slackware64-current/l"
  ~dependencies:[]
  ~version:"1.9.2"
  ~build:1
  ~sources:[
    "qt-everywhere-opensource-src-${VERSION}.tar.gz";
    "Qt.pc";
    "0001-configure-use-pkg-config-for-libpng.patch";
    "0001-windployqt-Fix-cross-compilation.patch";
    "0002-Use-widl-instead-of-midl.-Also-set-QMAKE_DLLTOOL-to-.patch";
    "0003-Tell-qmake-to-use-pkg-config.patch";
    "qt.fix.broken.gif.crash.diff.gz";
    "qt.mysql.h.diff.gz";
    "qt.webkit-no_Werror.patch.gz";
    "qt.yypkg.script";
    "qt5-dont-add-resource-files-to-qmake-libs.patch";
    "qt5-dont-build-host-libs-static.patch";
    "qt5-qmake-implib-dll-a.patch";
    "qt5-use-system-zlib-in-host-libs.patch";
    "qt5-workaround-qtbug-29426.patch";
  ]

