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

open Sources
open Common

let autoconf = add ("autoconf", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]
  ~version:Common.Version.autoconf
  ~build:1
  ~sources:[
    Common.Source.autoconf
  ]

let libtool = add ("libtool", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]
  ~version:Common.Version.libtool
  ~build:1
  ~sources:[
    Common.Source.libtool
  ]

let automake = add ("automake", None)
  ~dir:"slackware64-current/d"
  ~dependencies:[]
  ~version:Common.Version.automake
  ~build:1
  ~sources:[
    Common.Source.automake
  ]

let ocaml = add ("ocaml", None)
  ~dir:"slackbuilds.org/ocaml"
  ~dependencies:[]
  ~version:"4.01.0-trunk"
  ~build:2
  ~sources:[
    Tarball ("${PACKAGE}-${VERSION}.tar.gz", "8996881034bec1c222ed91259238ea151b42a11d");
  ]

let lua = add ("lua", None)
  ~dir:"slackbuilds.org/development"
  ~dependencies:[]
  ~version:"5.1.5"
  ~build:1
  ~sources:[
    Tarball ("${PACKAGE}-${VERSION}.tar.gz", "b3882111ad02ecc6b972f8c1241647905cb2e3fc");
    Patch "${PACKAGE}.pc";
    Patch "src_makefile";
  ]

let efl = add ("efl", Some "for-your-tools-only")
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[ lua ]
  ~version:Version.efl
  ~build:1
  ~sources:[ Source.efl ]

let elementary = add ("elementary", Some "regular")
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[ efl ]
  ~version:Version.elementary
  ~build:1
  ~sources:[ Source.elementary ]

let efl_git = add ("efl", Some "for-your-tools-only")
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[ lua ]
  ~version:"git"
  ~build:1
  ~sources:[ Source.efl_git ]

let elementary_git = add ("elementary", Some "regular-git")
  ~dir:"slackbuilds.org/libraries"
  ~dependencies:[ efl_git ]
  ~version:"git"
  ~build:1
  ~sources:[ Source.elementary_git ]

let qt = add ("qt", Some "native")
  ~dir:"slackware64-current/l"
  ~dependencies:[]
  ~version:"5.3.1"
  ~build:4
  ~sources:[
    Tarball ("qt-everywhere-opensource-src-${VERSION}.tar.xz", "66b33ea66eb05a864e7ae417179ea24c8a45ec10");
    Patch "Qt.pc";
    Patch "0001-configure-use-pkg-config-for-libpng.patch";
    Patch "0002-Use-widl-instead-of-midl.-Also-set-QMAKE_DLLTOOL-to-.patch";
    Patch "0003-Tell-qmake-to-use-pkg-config.patch";
    Patch "qt.fix.broken.gif.crash.diff.gz";
    Patch "qt.mysql.h.diff.gz";
    Patch "qt.webkit-no_Werror.patch.gz";
    Patch "qt.yypkg.script";
    Patch "qt5-dont-add-resource-files-to-qmake-libs.patch";
    Patch "qt5-dont-build-host-libs-static.patch";
    Patch "qt5-qmake-implib-dll-a.patch";
    Patch "qt5-use-system-zlib-in-host-libs.patch";
    Patch "qt5-workaround-qtbug-29426.patch";
  ]

let _all = add_full ("all", None)
  ~dir:""
  ~dependencies:[ autoconf; automake; libtool; lua; qt; efl; elementary ]
  ~version:"0.0.0"
  ~build:1
  ~sources:[]
  ~outputs:[]
