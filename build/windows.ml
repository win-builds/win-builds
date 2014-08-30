let builder ~cross ~name ~host =
  let open Config in
  let build = Arch.slackware in
  let prefix = Prefix.t ~build ~host ~target:host in
  let logs, yyoutput = Builder.logs_yyoutput ~nickname:prefix.Prefix.nickname in
  cross.Config.Builder.target_prefix <- Some prefix.Prefix.yyprefix;
  let open Arch in
  let open Prefix in
  let open Builder in
  {
    name;
    prefix; logs; yyoutput;
    path = Env.Prepend [ bindir cross.prefix; bindir Native_toolchain.builder.prefix ];
    pkg_config_path = Env.Clear;
    pkg_config_libdir = Env.Set [ Filename.concat prefix.libdir "pkgconfig" ] ;
    tmp = Env.Set [ Filename.concat prefix.Prefix.yyprefix "tmp" ];
    target_prefix = None; native_prefix = Some Native_toolchain.builder.prefix.Prefix.yyprefix;
    packages = [];
  }

let do_adds builder =
  let add_full = Config.Builder.register ~builder in
  let add = add_full ?outputs:None in

  let xz ~variant ~dependencies =
    add ("xz", Some variant)
      ~dir:"slackware64-current/a"
      ~dependencies
      ~version:"5.0.5"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "56f1d78117f0c32bbb1cfd40117aa7f55bee8765";
      ]
  in

  let libarchive ~variant ~dependencies =
    add ("libarchive", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"3.1.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "6a991777ecb0f890be931cec4aec856d1a195489";
      ]
  in

  let efl ~variant ~dependencies =
    add ("efl", Some variant)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies
      ~version:"1.11.0-beta1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "485b8cdd9eb4b7c0cfa0a1e5208b94043fd21bf7";
      ]
  in

  let elementary ~variant ~dependencies =
    add ("elementary", Some variant)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies
      ~version:"1.11.0-beta1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "f182ed80fda417cbd2c15a0b25fbf2d9d3652ca8";
      ]
  in

  let libjpeg ~variant ~dependencies =
    add ("libjpeg", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"v9a"
      ~build:2
      ~sources:[
        "jpegsrc.${VERSION}.tar.gz", "d65ed6f88d318f7380a3a5f75d578744e732daca";
      ]
  in

  let zlib ~variant ~dependencies =
    add ("zlib", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"1.2.8"
      ~build:1
      ~sources:[
        "zlib-${VERSION}.tar.xz", "961458ab8407e6192143b5f886ed8891e0def181";
      ]
  in

  let lua ~variant ~dependencies =
    add ("lua", Some variant)
      ~dir:"slackbuilds.org/development"
      ~dependencies
      ~version:"5.1.5"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "b3882111ad02ecc6b972f8c1241647905cb2e3fc";
        "${PACKAGE}.pc", "";
        "src_makefile", "";
      ]
  in

  let freetype ~variant ~dependencies =
    add ("freetype", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"2.5.0.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "9cd4182ca53c343fc8ac4dc41ab178567b4afd09";
        "freetype.illadvisederror.diff.gz", "";
        "freetype.subpixel.rendering.diff.gz", "";
      ]
  in

  let expat ~variant ~dependencies =
    add ("expat", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"2.1.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d739f9afeaf11fe231cbb0f684b69c7ba7dc11b7";
      ]
  in

  let dbus ~variant ~dependencies =
    add ("dbus", Some variant)
      ~dir:"slackware64-current/a"
      ~dependencies
      ~version:"1.6.12"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "340e8e09413040503f7afc0dd6ae97b78a52b517";
      ]
  in

  let _yypkg =
    let variant = "yypkg" in

    let libjpeg = libjpeg ~variant ~dependencies:[] in

    let zlib = zlib ~variant ~dependencies:[] in

    let lua = lua ~variant ~dependencies:[] in

    let freetype = freetype ~variant ~dependencies:[ zlib ] in

    let expat = expat  ~variant ~dependencies:[] in

    let dbus = dbus ~variant ~dependencies:[ expat ] in

    let xz = xz ~variant ~dependencies:[] in

    let libarchive = libarchive ~variant ~dependencies:[] in

    let efl = efl ~variant ~dependencies:[ dbus; freetype; lua; zlib; libjpeg ] in

    let elementary = elementary ~variant ~dependencies:[ efl ] in

    let ocaml_cryptokit = add ("ocaml-cryptokit", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[]
      ~version:"1.9"
      ~build:1
      ~sources:[
        "cryptokit-${VERSION}.tar.gz", "0dd76e76acc4dbee8175b9eca393df99b81fc096";
      ]
    in

    add ("yypkg", None)
      ~dir:""
      ~dependencies:[
        xz; libarchive; elementary; ocaml_cryptokit
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]

  in

  let _all =
    let mingw_w64_tool_add name = add (name, None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"v3.1.0"
      ~build:1
      ~sources:[
        "mingw-w64-${VERSION}.tar.bz2", "c167b1dc114a13c465fe6adcce9dc65c509baf75";
      ]
    in

    let winpthreads = add ("winpthreads", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"v3.1.0"
      ~build:2
      ~sources:[
        "mingw-w64-${VERSION}.tar.bz2", "";
      ]
    in

    let gendef = mingw_w64_tool_add "gendef" in

    let genidl = mingw_w64_tool_add "genidl" in

    let genpeimg = mingw_w64_tool_add "genpeimg" in

    let widl = mingw_w64_tool_add "widl" in

    let win_iconv = add ("win-iconv", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"0.0.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "51ce281cd8ce2debf3226482e86e0e534141ed01";
      ]
    in

    let gettext = add ("gettext", None)
      ~dir:"slackware64-current/a"
      ~dependencies:[ win_iconv ]
      ~version:"0.18.3.1"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "a32c19a6e39450748f6e56d2ac6b8b0966a5ab05";
      ]
    in

    let xz = xz ~variant:"regular" ~dependencies:[ gettext ] in

    let zlib = zlib ~variant:"regular" ~dependencies:[] in

    let libjpeg = libjpeg ~variant:"regular" ~dependencies:[] in

    let expat = expat ~variant:"regular" ~dependencies:[] in

    let libpng = add ("libpng", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ zlib ]
      ~version:"1.4.12"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "88972bbd8b7625c7d7c90f395cda1e4bb68a702c";
      ]
    in

    let freetype = freetype ~variant:"regular" ~dependencies:[ zlib; libpng ] in

    let fontconfig = add ("fontconfig", None)
      ~dir:"slackware64-current/x"
      ~dependencies:[ freetype; expat ]
      ~version:"2.11.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "4f83bab1834f60345f1ef3920ac393d9f9c609ab";
      ]
    in

    let giflib = add ("giflib", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"4.1.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "b38d1f77afb1ea554acadeb3401cb34c6b8bf16b";
      ]
    in

    let libtiff = add ("libtiff", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libjpeg ]
      ~version:"3.9.7"
      ~build:1
      ~sources:[
        "tiff-${VERSION}.tar.xz", "92dd9600b3b7c0a1ec7a8b1d790c089cfe30ff2c";
        "tiff-${VERSION}_CVE-2012-4447_CVE-2012-4564_CVE-2013-1960_CVE-2013-1961.diff.gz", "";
        "tiff-${VERSION}_CVE-2013-4231.diff.gz", "";
        "tiff-${VERSION}_CVE-2013-4232.diff.gz", "";
        "tiff-${VERSION}_CVE-2013-4244.diff.gz", "";
      ]
    in

    let lua = lua ~variant:"regular" ~dependencies:[] in

    let ca_certificates = add ("ca-certificates", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[]
      ~version:"20130906"
      ~build:1
      ~sources:[
        "${PACKAGE}_${VERSION}.tar.gz", "7f197c1bf7c7fc82e9f8f2fec6d8cc65f6a6187b";
      ]
    in

    let openssl = add ("openssl", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ ca_certificates ]
      ~version:"1.0.1i"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "74eed314fa2c93006df8d26cd9fc630a101abd76";
      ]
    in

    let gmp = add ("gmp", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"5.1.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "12cfe0911d64fcbd85835df9ddc18c99af8f9a45";
      ]
    in

    let nettle = add ("nettle", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[]
      ~version:"2.7.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "48dac2b55a07e6cf4ebf74d069f0c26e7019ce99";
      ]
    in

    let libtasn1 = add ("libtasn1", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "5d480b83526264a216b5822c2dcbffad26a792d9";
      ]
    in

    let gnutls = add ("gnutls", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ zlib; gmp; libtasn1; nettle; ca_certificates ]
      ~version:"3.2.15"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "31f289b48b0bf054f5f8c16d3b878615d0ae06fc";
      ]
    in

    let curl = add ("curl", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ ca_certificates ]
      ~version:"7.36.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "c39b120585a8a8d64ef14459d6d5f22831d4a7c4";
      ]
    in

    let c_ares = add ("c-ares", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"1.10.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "e44e6575d5af99cb3a38461486e1ee8b49810eb5";
      ]
    in

    let pixman = add ("pixman", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"0.32.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d136a0007e9bd24841a5324b01ce867892f997c7";
      ]
    in

    let libffi = add ("libffi", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.0.13"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "03589fae4c732585476f5d93f691bbc446187ef7";
      ]
    in

    let glib2 = add ("glib2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libffi ]
      ~version:"2.36.4"
      ~build:1
      ~sources:[
        "glib-${VERSION}.tar.xz", "ae189818c9f4ae8e404cc17c195f3e1c644fd97a";
      ]
    in

    let cairo = add ("cairo", None)
      ~dir:"slackware64-current/l"
      (* TODO: seems to be able to use pthread *)
      ~dependencies:[ pixman; freetype; fontconfig; libpng ]
      ~version:"1.12.16"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "fce23fb9f2af3fe18c0214551e68712d401f6ef4";
      ]
    in

    let atk = add ("atk", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"2.8.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "e8a9dacd22b31a6cb733ce66fb1c220cc6720970";
      ]
    in

    let pango = add ("pango", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.34.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "a6c224424eb3f0dcc231a8000591c05a85df689c";
      ]
    in

    let gdk_pixbuf2 = add ("gdk-pixbuf2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"2.28.2"
      ~build:1
      ~sources:[
        "gdk-pixbuf-${VERSION}.tar.xz", "9876d0a20f592f8fb2a52d4a86ec43d607661beb";
        "gdk-pixbuf.pnglz.diff.gz", "";
      ]
    in

    let gtk_2 =
      let dir =
        if Config.(builder.Builder.prefix.Prefix.host = Arch.windows_64) then
          ""
        else
          "slackware64-current/l"
      in
      add ("gtk+2", None)
        ~dir
        ~dependencies:[ gdk_pixbuf2; pango; atk; cairo; glib2 ]
        ~version:"2.24.20"
        ~build:1
        ~sources:[
          "gtk+-${VERSION}.tar.xz", "89315bf05dd3d626a50bae5417942ee4428012c9";
          "gtk+-2.24.x.icon-compat.am.diff.gz", "";
          "gtk+-2.24.x.icon-compat.diff.gz", "";
        ]
    in

    let glib_networking = add ("glib-networking", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ glib2 ]
      ~version:"2.36.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d4c2accd50ff4769f434cd552734fb2b0b2b3b81";
      ]
    in

    let libxml2 = add ("libxml2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"2.9.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "dfefed2ce782fdeb956878d51918cc82ba2ebbfb";
      ]
    in

    let sqlite = add ("sqlite", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[]
      ~version:"3071700"
      ~build:1
      ~sources:[
        "${PACKAGE}-src-3071700.tar.xz", "eb5e12337d29ce2da9a9ed9b1d69f6c66c2e4877";
        "COPYRIGHT.gz", "";
        "configure.ac", "";
      ]
    in

    let libsoup = add ("libsoup", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ glib2; sqlite ]
      ~version:"2.42.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "8d2a660879c4cf00379ceab04c3e479dedd1405c";
      ]
    in

    let icu4c = add ("icu4c", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"51.2" (* NOTE: the version number in sources needs updating too *)
      ~build:2
      ~sources:[
        "${PACKAGE}-51_2-src.tar.xz", "c50ed0a3870478d81ac5f7d765619f83e9be6032";
      ]
    in

    let gperf = add ("gperf", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"3.0.4"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "78ea1a5660538bfa35bb5ccec9b18a0ec68e9e87";
      ]
    in

    let mpfr = add ("mpfr", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.1.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "03e593cc6e26639ef5e60be1af8dc527209e5172";
      ]
    in

    let libmpc = add ("libmpc", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.8.2"
      ~build:2
      ~sources:[
        "mpc-${VERSION}.tar.xz", "1a8a84a04aef025b690cbbdd299e745dd7416514";
      ]
    in

    let libogg = add ("libogg", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.3.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d74e7514f268d58a171b4b9baf15602fd8060c33";
      ]
    in

    let libvorbis = add ("libvorbis", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libogg ]
      ~version:"1.3.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "31d1a0ec4815bf1ee638b0f2850f03efcd48022a";
      ]
    in

    let libtheora = add ("libtheora", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libvorbis ]
      ~version:"1.1.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "800aa48cf9e59d546c18ecdac1d06d7643cbb2d3";
      ]
    in

    let fribidi = add ("fribidi", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.19.2"
      ~build:3
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "dc844759c129cfe7b389873458175414411768b2";
      ]
    in

    let libsndfile = add ("libsndfile", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.0.25"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "cfd2c6eaaed3bce1e90140cf899cf2358348944f";
      ]
    in

    let dbus = dbus ~variant:"regular" ~dependencies:[ expat ] in

    let harfbuzz = add ("harfbuzz", None)
      ~dir:"slackware64-current/l"
      (* TODO: the cairo dependency is only build-time; what about the others? *)
      ~dependencies:[ cairo; freetype; glib2; icu4c ]
      ~version:"0.9.16"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d7fa8ef7f2eca07e29d94f448f6196c9b3022d64";
      ]
    in

    let efl = efl ~variant:"regular" ~dependencies:[
      libtiff; libpng; giflib; libjpeg;
      fontconfig; freetype; lua;
      fribidi; harfbuzz; libsndfile;
      gnutls; curl; c_ares; dbus;
    ]
    in

    let elementary = elementary ~variant:"regular" ~dependencies:[ efl ] in

    let pkg_config = add ("pkg-config", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"0.25"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d2e75fcdbda33cf1577a76b7b2beaa408f2aa299";
      ]
    in

    let libarchive = libarchive ~variant:"yypkg" ~dependencies:[] in

    let wget = add ("wget", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ openssl ]
      ~version:"1.14"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "cfa0906e6f72c1c902c29b52d140c22ecdcd617e";
      ]
    in

    let mingw_w64 = add ("mingw-w64", Some "full")
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"v3.1.0"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "c167b1dc114a13c465fe6adcce9dc65c509baf75";
      ]
    in

    let binutils = add ("binutils", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"2.24"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "1b2bc33003f4997d38fadaa276c1f0321329ec56";
        "binutils.export.demangle.h.diff.gz", "";
        "binutils.no-config-h-check.diff.gz", "";
      ]
    in

    let gcc = add_full ("gcc", Some "full")
      ~dir:"slackware64-current/d"
      ~dependencies:[ gmp; mpfr; libmpc ]
      ~version:"4.8.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "f2f894d6652f697fede264c16c028746e9ee6243";
      ]
      ~outputs:[
        "gcc-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz";
        "gcc-g++-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz"
      ]
    in

    let x264 = add ("x264", None)
      ~dir:"slackbuilds.org/multimedia"
      ~dependencies:[]
      ~version:"20131101"
      ~build:1
      ~sources:[
        "${PACKAGE}-snapshot-${VERSION}-2245-stable.tar.bz2", "3c838a7979f8962bac27de5078984cf3b6e2c210";
      ]
    in

    let pcre = add ("pcre", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"8.33"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "ddfa04311c01a3882943814a3cd577080c877a8a"
      ]
    in

    let libao = add ("libao", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.1.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "9301bc4886f170c7122ab62677fb71cf001c04fd";
      ]
    in

    let flac = add ("flac", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[ libao (* TODO: check *) ]
      ~version:"1.2.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "8a979b348cd641ff7ac7023046dc693683a77dba";
        "flac.gcc45.diff.gz", "";
        "flac.man.diff.gz", "";
      ]
    in

    let gdb = add ("gdb", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"7.8"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "fc43f1f2e651df1c69e7707130fd6864c2d7a428";
      ]
    in

    let libmad = add ("libmad", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.15.1b"
      ~build:3
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "cac19cd00e1a907f3150cc040ccc077783496d76";
        "Makefile.am", "";
        "configure.ac", "";
        "mad.pc.in", "";
      ]
    in

    let libid3tag = add ("libid3tag", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.15.1b"
      ~build:4
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "4d867e8a8436e73cd7762fe0e85958e35f1e4306";
      ]
    in

    let madplay = add ("madplay", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[ libid3tag; libmad ]
      ~version:"0.15.2b"
      ~build:4
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "9012438e8be93068e271df0dbeaaefae0320a1a5";
        "${PACKAGE}-${VERSION}-fix-segfault.patch.gz", "";
      ]
    in

    let lcms = add ("lcms", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ zlib; libtiff; libjpeg ]
      ~version:"1.19"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "f10eca160062562fabd4e9c7c8fb65db61da9dbf";
      ]
    in

    let lcms2 = add ("lcms2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"2.4"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "ba6d7b21cf500301634be1381809d27bcd96522c";
      ]
    in

    let djvulibre = add ("djvulibre", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.5.25.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "66e3f4f2c5db863eb5a32ff31d4b01faaa5e1916";
        "patches/0047-djvused-added-missing-command-remove-outline.patch", "";
        "patches/0053-portable-pthread_t-initialization.patch", "";
        "patches/0056-remove-extra-semi-in-test-for-std-c-includes.patch", "";
        "patches/0058-fixed-for-mingw.patch", "";
        "patches/0059-Attempt-to-work-around-typename-issues.patch", "";
        "patches/0060-more-mingw-fixes.patch", "";
        "patches/0061-removed-gstring-cruft.patch", "";
        "patches/0063-windows-recompile-reveals-issues.patch", "";
        "patches/0072-handle-period-in-crlf-files-as-well.patch", "";
        "patches/0077-fix-for-filename-conversion.patch", "";
        "patches/0079-locale-changes-for-win32.patch", "";
        "patches/0088-fixed-trivial-crash.patch", "";
        "patches/0094-meta-data-metadata.patch", "";
        "patches/0105-Fixed-small-bugs-from-Maks.patch", "";
        "patches/0107-Added-the-magic-win32-dll-option-in-LT_INIT-see-bug-.patch", "";
        "patches/0108-Cast-pointers-to-size_t-instead-of-unsigned-long.patch", "";
        "patches/0109-Added-code-to-define-inline-when-using-C.patch", "";
        "patches/0115-Fixed-clang-warnings.patch", "";
      ]
    in

    let dejavu_fonts_ttf = add ("dejavu-fonts-ttf", None)
      ~dir:"slackware64-current/x"
      ~dependencies:[]
      ~version:"2.34"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "bde72791923ac34de00e396a176307b8b71bd1a1";
      ]
    in

    let opus = add ("opus", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"1.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "35005f5549e2583f5770590135984dcfce6f3d58";
      ]
    in

    let a52dec = add ("a52dec", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"0.7.4"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "79b33bd8d89dad7436f85b9154ad35667aa37321";
      ]
    in

    let libmpeg2 = add ("libmpeg2", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"0.5.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "0f9163d8fd52db5f577ebe45636f674252641fd7";
      ]
    in

    let libsigc_plus_plus = add ("libsigc++", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"2.2.11"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "bbec3d8c54a17f19d63f9decbb91b0d79ea0d02e";
      ]
    in

    let jansson = add ("jansson", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"2.5"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "144e31826b7ab9a648511759c43b23db5865f4db";
      ]
    in

    (* let opencore_amr = add ("opencore-amr", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"0.1.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz";
      ]
    in *)

    (* let faad2 = add ("faad2", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"2.7"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2";
      ]
    in *)

    let lame = add ("lame", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"3.99.5"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "03a0bfa85713adcc6b3383c12e2cc68a9cfbf4c4";
      ]
    in

    let qt = add ("qt", Some "regular")
      ~dir:"slackware64-current/l"
      ~dependencies:[ icu4c; zlib; sqlite; pcre; libpng; libjpeg; harfbuzz; dbus;
        (* freetype; (* build with -system-freetype is broken and probably unsupported *) *)
        (* win_iconv (* disabled by default in the build *) *)
        (* giflib (* Qt never uses the sytem one! *) *)
      ]
      ~version:"5.3.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-everywhere-opensource-src-${VERSION}.tar.gz", "3244dd34f5fb695e903eaa49c6bd0838b9bf7a73";
        "0001-configure-use-pkg-config-for-libpng.patch", "";
        "0002-Use-widl-instead-of-midl.-Also-set-QMAKE_DLLTOOL-to-.patch", "";
        "0003-Tell-qmake-to-use-pkg-config.patch", "";
        "Qt.pc", "";
        "qt.fix.broken.gif.crash.diff.gz", "";
        "qt.mysql.h.diff.gz", "";
        "qt.webkit-no_Werror.patch.gz", "";
        "qt5-dont-add-resource-files-to-qmake-libs.patch", "";
        "qt5-dont-build-host-libs-static.patch", "";
        "qt5-qmake-implib-dll-a.patch", "";
        "qt5-qmake-implib-dll-a.patch~", "";
        "qt5-use-system-zlib-in-host-libs.patch", "";
        "qt5-workaround-qtbug-29426.patch", "";
      ]
    in

    let ffmpeg = add ("ffmpeg", None)
      ~dir:"slackbuilds.org/multimedia"
      ~dependencies:[ lame; x264; opus; libtheora; libvorbis; flac (* XXX: used? *) ]
      ~version:"2.2.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "945e18bf910ae14519eabf8e585e2e946dd58660";
      ]
    in

    let make = add ("make", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"4.0"
      ~build:5
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "b092020919f74d56118eafac2c202f25ff3b6e59";
      ]
    in

    let json_c = add ("json-c", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"0.12"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "5580aad884076c219d41160cbd8bc12213d12c37";
        "remove-unused-variable-size.patch", "";
      ]
    in

    let libgpg_error = add ("libgpg-error", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[]
      ~version:"1.13"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "50fbff11446a7b0decbf65a6e6b0eda17b5139fb";
      ]
    in

    let libgcrypt = add ("libgcrypt", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ libgpg_error ]
      ~version:"1.6.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "f03d9b63ac3b17a6972fc11150d136925b702f02";
      ]
    in

    let sdl2 = add ("SDL2", None)
      ~dir:"slackbuilds.org/development"
      ~dependencies:[ win_iconv ]
      ~version:"2.0.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "21c45586a4e94d7622e371340edec5da40d06ecc";
      ]
    in

    let openjpeg = add ("openjpeg", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[ lcms; lcms2 ]
      ~version:"2.1.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "c2a255f6b51ca96dc85cd6e85c89d300018cb1cb";
      ]
    in

    let libxslt = add ("libxslt", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libxml2 ]
      ~version:"1.1.28"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "ac0ca9da86581844ae8e77598b2d47a6d2432017";
      ]
    in

    let libdvdread = add ("libdvdread", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"4.2.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "431bc92195f27673bfdd2be67ce0f58338da8d3b";
      ]
    in

    let sox = add ("sox", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[
        libao; libmad; libid3tag; lame; libvorbis; libogg; libsndfile; ffmpeg;
        (* NOTE: available: wavpack *)
        (* NOTE: available: magic *)
        (* NOTE: available: libpng ! *)
      ]
      ~version:"14.4.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "6df5d814edeb1b46354f8493507710ea95fefb2c";
      ]
    in

    let zz_config = add ("zz_config", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"1.0.0"
      ~build:3
      ~sources:[
        "win-builds-switch", "";
      ]
    in

    add ("all", None)
      ~dir:""
      ~dependencies:[
        gcc; binutils; mingw_w64; gdb;
        elementary; gtk_2; ffmpeg;
        libtheora; opus; sox;
        madplay; icu4c; make; gperf; zz_config;
        jansson; libsigc_plus_plus;
        zlib; xz; winpthreads; pkg_config; libarchive;
        wget; dejavu_fonts_ttf;
        openjpeg; sdl2; libgcrypt;
        glib_networking; libxml2; libsoup; djvulibre; a52dec; libmpeg2;
        pcre; libxslt; libdvdread;
        gendef; genidl; genpeimg; widl;
        json_c;
        qt;
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]

  in

  let _experimental =
    let _libidn = add ("libidn", None)
      (* NOTE: Uses gnulib with MSVC bits licensd as GPLv3; *NOT* LGPL. *)
      (* NOTE: Wget can depend on libidn (wget's license has to be checked). *)
      (* NOTE: Also, the gnulib MSVC bits don't compile; maybe an update would
       *       fix them. *)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.25"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "e1b18e18b0eca1852baff7ca55acce42096479da";
      ]
    in

    (* NOTE: dependency on regex *)
    (* NOTE: has an enum field "SEARCH_ALL" which conflicts with a #define from
     *       Windows and is public API. *)
    let _libcddb = add ("libcddb", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.3.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "1869ff09b522b9857f242ab4b06c5e115f46ff14";
      ]
    in

    (* TODO: check for new version *)
    (* TODO: check why it might try to build cdparanoia *)
    (* TODO: cdtext.c:216:3: warning: implicit declaration of function ‘bzero’
     *       [-Wimplicit-function-declaration] *)
    let _libcdio = add ("libcdio", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ _libcddb ]
      ~version:"0.83"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "dc03799b2ab878def5e0517d70f65a91538e9bc1";
      ]
    in

    add ("experimental", None)
      ~dir:""
      ~dependencies:[
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]

    (* 
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

      let gucharmap = add ("gucharmap", None)
        ~dir:"slackware64-current/xap"
        ~dependencies:[ gtk_3 ]

      (* includes <pwd.h> *)
      let geeqie = add ("geeqie", None)
        ~dir:"slackware64-current/xap"
        ~dependencies:[]

      let luajit = add ("luajit", None)
        ~dir:"slackbuilds.org/development"
        ~dependencies:[]

      let file = add ("file", None)
        ~dir:"slackware64-current/a"
        ~dependencies:[]

      let cdparanoia = add ("cdparanoia", None)
        ~dir:"slackware64-current/ap"
        ~dependencies:[ libcdio? ]

      let fdk_aac = add ("fdk-aac", None)
        ~dir:"mingw"
        ~dependencies:[]
        ~version:"2.34"
        ~build:1
        ~sources:[
          "${PACKAGE}-${VERSION}.tar.xz";
        ]
      in

    *)

  in

  let _disabled =
    let _speex = add ("speex", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[ (* libogg *) ]
      ~version:"1.2rc1"
      ~build:3
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "52daa72572e844e5165315e208da539b2a55c5eb";
      ]
    in

    add ("disabled", None)
      ~dir:""
      ~dependencies:[
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]

  in

  ()

let builder_32 =
  builder ~name:"windows_32" ~host:Config.Arch.windows_32 ~cross:Cross_toolchain.builder_32
let builder_64 =
  builder ~name:"windows_64" ~host:Config.Arch.windows_64 ~cross:Cross_toolchain.builder_64

let () =
  do_adds builder_32;
  do_adds builder_64
