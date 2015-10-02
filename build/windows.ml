let do_adds builder =
  let open Sources in
  let add = Worker.register ~builder in

  let libarchive_add ~variant ~dependencies =
    add ("libarchive", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"3.1.2"
      ~build:(if variant = "regular" then 1 else -1)
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.gz", "6a991777ecb0f890be931cec4aec856d1a195489");
        Patch "0001-windows-don-t-undef-stat-since-it-my-be-defined-to-s.patch";
        Patch "use-static-asserts-to-guarantee-abi-compatibility.patch";
      ]
  in

  let _all =

#use "slackware64-current/d/autoconf/wb.ml"
#use "slackware64-current/d/libtool/wb.ml"
#use "slackware64-current/d/automake/wb.ml"
#use "mingw/mingw-w64/wb:common.ml"
#use "mingw/mingw-w64/wb:headers.ml"
  let mingw_w64_full = mingw_w64_add ("mingw-w64", Some "full")
    ~build:2
    ~dependencies:[]
  in
  let winpthreads = mingw_w64_add ("mingw-w64", None)
    ~dependencies:[]
    ~build:2
  in
let geoip = add ("GeoIP", None)
  ~dir:"slackbuilds.org/network"
  ~dependencies:[]
  ~native_deps:[ "autoconf"; "automake"; "libtool" ]
  ~version:"1.6.5"
  ~build:1
  ~sources:[Tarball ("GeoIP-${VERSION}.tar.gz", "bf29626ea665c3302059853ad41b31ea42daed1e");]
in
let libmaxminddb = add ("libmaxminddb", None)
  ~dir:"slackbuilds.org/network"
  ~dependencies:[]
  ~version:"1.0.4"
  ~build:1
  ~sources:[Tarball ("libmaxminddb-${VERSION}.tar.gz", "57548d426d43b9b43c77786b08594d48d0c88c62");]
in
#use "mingw/gendef/wb.ml"
#use "mingw/genidl/wb.ml"
#use "mingw/genpeimg/wb.ml"
#use "mingw/libmangle/wb.ml"
#use "mingw/winstorecompat/wb.ml"
#use "mingw/widl/wb.ml"
#use "mingw/win-iconv/wb.ml"
#use "slackware64-current/a/gettext/wb.ml"
    let gettext = add (gettext_name, gettext_variant)
      ~dir:gettext_dir
      ~dependencies:[ win_iconv ]
      ~version:gettext_version
      ~build:gettext_build
      ~sources:gettext_sources
    in

#use "slackware64-current/a/xz/wb:common.ml"
    let xz = xz_add ~variant:"regular" ~dependencies:[ gettext ] in

#use "slackware64-current/l/zlib/wb:regular.ml"
#use "slackware64-current/l/libjpeg-turbo/wb.ml"
#use "slackware64-current/l/expat/wb:regular.ml"
#use "slackware64-current/l/libpng/wb.ml"
#use "slackware64-current/l/freetype/wb.ml"
#use "slackware64-current/x/fontconfig/wb:common.ml"

    let fontconfig = fontconfig_add ~variant:"regular" ~dependencies:[ freetype; expat ] in

#use "slackware64-current/l/giflib/wb.ml"
#use "slackware64-current/l/libtiff/wb.ml"
#use "slackbuilds.org/development/lua/wb:regular.ml"
#use "slackware64-current/n/ca-certificates/wb.ml"
#use "slackware64-current/n/openssl/wb.ml"
#use "slackware64-current/l/gmp/wb.ml"
#use "slackware64-current/n/nettle/wb.ml"
#use "slackware64-current/l/libtasn1/wb.ml"
#use "slackware64-current/n/gnutls/wb.ml"
#use "slackware64-current/n/curl/wb.ml"
#use "slackbuilds.org/libraries/c-ares/wb.ml"
#use "mingw/pixman/wb.ml"
#use "slackware64-current/a/bzip2/wb.ml"
#use "slackware64-current/l/pcre/wb.ml"
#use "slackware64-current/l/libffi/wb.ml"
#use "slackware64-current/l/glib2/wb.ml"
#use "slackware64-current/d/pkg-config/wb:common.ml"
#use "slackware64-current/d/pkg-config/wb.ml"
#use "slackware64-current/l/cairo/wb.ml"
#use "slackware64-current/l/atk/wb.ml"
#use "slackware64-current/l/icu4c/wb.ml"
#use "slackware64-current/l/harfbuzz/wb.ml"
#use "slackware64-current/l/pango/wb.ml"
#use "slackware64-current/l/gdk-pixbuf2/wb.ml"
#use "slackware64-current/l/gtk+2/wb.ml"
#use "slackware64-current/l/gtk+3/wb.ml"
#use "slackware64-current/xap/gucharmap/wb.ml"
#use "slackware64-current/l/glib-networking/wb.ml"
#use "slackware64-current/l/libxml2/wb.ml"
#use "slackware64-current/l/libcroco/wb.ml"

    let gettext_tools = add ("gettext-tools", None)
      ~dir:"slackware64-current/d"
      (* check that it indeed depends on gettext *)
      ~dependencies:[ libcroco; gettext ]
      ~version:gettext_version
      ~build:gettext_build
      ~sources:gettext_sources
    in

#use "slackware64-current/ap/sqlite/wb.ml"
#use "slackware64-current/l/libsoup/wb.ml"
#use "slackware64-current/d/gperf/wb.ml"
#use "slackware64-current/l/mpfr/wb.ml"
#use "slackware64-current/l/libmpc/wb.ml"
#use "slackware64-current/l/libogg/wb.ml"
#use "slackware64-current/l/libvorbis/wb.ml"
#use "slackware64-current/l/libtheora/wb.ml"
#use "slackware64-current/l/fribidi/wb.ml"
#use "slackbuilds.org/development/check/wb.ml"
#use "slackware64-current/a/dbus/wb:common.ml"

    let dbus = dbus_add ~variant:"regular" ~dependencies:[ expat ] in

    let libarchive = libarchive_add ~variant:"regular" ~dependencies:[ nettle ] in

#use "slackware64-current/n/wget/wb.ml"
    let binutils_dependencies = [ zlib ] in
#use "slackware64-current/d/binutils/wb.ml"
#use "slackware64-current/d/gcc/wb:core.ml"
    let gcc_dependencies = [ binutils; mpfr; gmp; libmpc; winpthreads ] in
#use "slackware64-current/d/gcc/wb:full.ml"

#use "slackbuilds.org/multimedia/x264/wb.ml"
#use "slackware64-current/l/libao/wb.ml"
#use "slackware64-current/ap/flac/wb.ml"
#use "slackware64-current/l/lcms/wb.ml"
#use "slackware64-current/l/lcms2/wb.ml"
#use "slackbuilds.org/libraries/bullet/wb.ml"
#use "slackware64-current/l/openjpeg/wb.ml"
#use "slackware64-current/l/libsndfile/wb.ml"
#use "slackware64-current/l/orc/wb.ml"
#use "slackware64-current/l/gstreamer/wb.ml"
#use "slackware64-current/l/gst-plugins-base/wb.ml"
#use "slackware64-current/l/gst-plugins-good/wb.ml"
#use "slackbuilds.org/libraries/efl/wb:common.ml"
#use "slackbuilds.org/libraries/efl/wb:common-git.ml"
#use "slackbuilds.org/libraries/efl/wb:regular.ml"
#use "slackbuilds.org/libraries/efl/wb:regular-git.ml"
#use "slackbuilds.org/libraries/elementary/wb:regular.ml"
#use "slackbuilds.org/libraries/elementary/wb:regular-git.ml"
#use "slackware64-current/d/gdb/wb.ml"
#use "slackware64-current/l/libmad/wb.ml"
#use "slackware64-current/l/libid3tag/wb.ml"
#use "slackware64-current/ap/madplay/wb.ml"
#use "slackware64-current/l/djvulibre/wb.ml"
#use "slackware64-current/x/dejavu-fonts-ttf/wb.ml"
#use "slackbuilds.org/audio/opus/wb.ml"
#use "slackware64-current/l/a52dec/wb.ml"
#use "slackbuilds.org/libraries/libmpeg2/wb.ml"
#use "slackbuilds.org/libraries/libsigc++/wb.ml"
#use "slackbuilds.org/libraries/jansson/wb.ml"
#use "slackbuilds.org/libraries/lame/wb.ml"
#use "slackware64-current/l/qt/wb:regular.ml"

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

#use "slackbuilds.org/audio/speex/wb.ml"
#use "slackbuilds.org/multimedia/ffmpeg/wb.ml"
#use "slackware64-current/d/make/wb.ml"
#use "slackbuilds.org/libraries/json-c/wb.ml"
#use "slackware64-current/n/libgpg-error/wb.ml"
#use "slackware64-current/n/libgcrypt/wb.ml"
#use "slackbuilds.org/development/SDL2/wb.ml"
#use "slackware64-current/l/libxslt/wb.ml"
#use "slackware64-current/l/libdvdread/wb.ml"
#use "slackware64-current/l/libdvdnav/wb.ml"
#use "slackbuilds.org/libraries/libdvdcss/wb.ml"
#use "slackware64-current/ap/sox/wb.ml"
#use "slackware64-current/l/babl/wb.ml"
#use "slackware64-current/l/gegl/wb.ml"
#use "slackware64-current/xap/gimp/wb.ml"
#use "slackware64-current/l/boost/wb.ml"
#use "mingw/zz_config/wb.ml"

    let ocaml_findlib = add ("ocaml-findlib", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[]
      ~version:"1.5.2"
      ~build:1
      ~sources:[
        Tarball ("findlib-${VERSION}.tar.gz", "4c37dabd03abe5b594785427d8f5e4adf60e6d9f");
        Patch "findlib.conf.in";
      ]
    in

    let ocaml_cryptokit = add ("ocaml-cryptokit", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[ ocaml_findlib ]
      ~version:"1.9"
      ~build:1
      ~sources:[
        Tarball ("cryptokit-${VERSION}.tar.gz", "2e90f27d05fe68a79747e64eef481835291babf4");
      ]
    in

    let ocaml_fileutils = add ("ocaml-fileutils", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[ ocaml_findlib ]
      ~version:"0.4.5"
      ~build:1
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.gz", "94d02385a55eef373eb96f256068d3efa724016b");
        Patch "0001-FileUtil-replace-stat.is_link-boolean-with-a-Link-va.patch";
        Patch "0002-FileUtil-symlinks-patch-2.patch";
      ]
    in

    let libocaml_http =
      let libocaml_add subpackage ~dependencies ~sha1 =
        add ("libocaml_" ^ subpackage, None)
          ~dir:"slackbuilds.org/ocaml"
          ~dependencies:(ocaml_findlib :: dependencies)
          ~version:"v2014-08-08"
          ~build:1
          ~sources:[ Tarball ("${PACKAGE}.${VERSION}.tar.xz", sha1) ]
      in

      let exception_ = libocaml_add "exception"
        ~dependencies:[]
        ~sha1:"69c73123a46f9bc3f3b9a6ec13074d7009d8829b"
      in

      let option_ = libocaml_add "option"
        ~dependencies:[]
        ~sha1:"06401a24a9fc86a796c5ca9dd24a38c7d761cfea"
      in

      let lexing = libocaml_add "lexing"
        ~dependencies:[ exception_ ]
        ~sha1:"3d8ad03b73f423f2dc35e8fc8d77eb662b99c7e7"
      in

      let plus = libocaml_add "plus"
        ~dependencies:[ exception_ ]
        ~sha1:"ee63b54f3be5e855c4b7995dd29e384b09ce5ff6"
      in

      let ipv4_address = libocaml_add "ipv4_address"
        ~dependencies:[ exception_; option_ ]
        ~sha1:"2cf54d0e9e77b9ed61ecd2ad3c9cfe4a50c79513"
      in

      let ipv6_address = libocaml_add "ipv6_address"
        ~dependencies:[ exception_; lexing ]
        ~sha1:"12498c816ce3e10bd945f9d6dd4eff01c2400df7"
      in

      let uri = libocaml_add "uri"
        ~dependencies:[
           exception_; ipv4_address; ipv6_address; lexing; option_; plus
         ]
        ~sha1:"7335da49acfdd61f262bd41e417e422f7ee2e9c2"
      in

      libocaml_add "http"
        ~dependencies:[ lexing; option_; plus; uri ]
        ~sha1:"79a164edaa5421e987883a87a4643a86cac8c971"
    in

    let ocaml_efl = add ("ocaml-efl", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[ ocaml_findlib; elementary ]
      ~version:"1.11.1"
      ~build:1
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.xz", "c06511ef058d0676ff1873515e3b07af0e2a987a");
      ]
    in

    let _yypkg =
      let variant = "yypkg" in

      let dbus = dbus_add ~variant ~dependencies:[ expat ] in

      let harfbuzz = harfbuzz_add ~variant:(Some variant) ~dependencies:[ freetype ] in

      let fontconfig = fontconfig_add ~variant ~dependencies:[ freetype; expat ] in

      let xz = xz_add ~variant ~dependencies:[] in

      let libarchive = libarchive_add ~variant ~dependencies:[ xz ] in

      let ocaml_archive = add ("ocaml-archive", None)
        ~dir:"slackbuilds.org/ocaml"
        ~dependencies:[ libarchive; ocaml_findlib; ocaml_fileutils ]
        ~version:"2.8.4+2"
        ~build:1
        ~sources:[
          Tarball ("${PACKAGE}-${VERSION}.tar.gz", "4705e7eca920f6d831f2b8020d648d7caa18bb04");
          Patch "0001-_oasis-make-it-possible-to-not-build-tests-docs-and-.patch";
          Patch "0002-Bind-extract-set_pathname-and-read_open_memory-strin.patch";
          Patch "0003-stubs-bind-archive_entry_-set_-pathname-through-a-ma.patch";
          Patch "0004-Bind-archive_entry_-set_-hard-sym-link-and-archive_e.patch";
        ]
      in

      add ("yypkg", None)
        ~dir:"slackbuilds.org/ocaml"
        ~dependencies:[ ocaml_findlib; ocaml_cryptokit;
            ocaml_fileutils; ocaml_archive; ocaml_efl; libocaml_http;
            dbus; harfbuzz; fontconfig; libarchive
        ]
        ~version:"1.9.0"
        ~build:1
        ~sources:[
          Tarball ("${PACKAGE}-${VERSION}.tar.xz", "f3d9d39037420f04c0155410b193f7d3a48ec486");
        ]
    in

#extras

    add ("all", None)
      ~dir:""
      ~dependencies:[
        autoconf; automake; libtool; gettext_tools;
        gcc_full; binutils; mingw_w64_full; gdb;
        elementary; gtk_2; gtk_3; gucharmap; ffmpeg;
        libtheora; opus; sox;
        madplay; icu4c; make; gperf; zz_config;
        jansson; libsigc_plus_plus;
        zlib; xz; winpthreads; pkg_config; libarchive;
        wget; dejavu_fonts_ttf;
        libjpeg_turbo; openjpeg; sdl2; libgcrypt;
        glib_networking; libxml2; libsoup; djvulibre; a52dec; libmpeg2;
        pcre; libxslt; libdvdread; libdvdnav; libdvdcss;
        gendef; genidl; genpeimg; widl; libmangle; winstorecompat;
        babl; gegl; gimp; gstreamer1; gst1_plugins_good; bullet;
        json_c;
        qt;
        check;
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]

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
        Tarball ("${PACKAGE}-${VERSION}.tar.xz", "e1b18e18b0eca1852baff7ca55acce42096479da");
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
        Tarball ("${PACKAGE}-${VERSION}.tar.xz", "1869ff09b522b9857f242ab4b06c5e115f46ff14");
      ]
    in

    let _pdcurses = add ("PDCurses", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"3.4"
      ~build:1
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.gz", "e36684442a6171cc3a5165c8c49c70f67db7288c");
      ]
    in

    let _readline = add ("readline", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ _pdcurses ]
      ~version:"5.2"
      ~build:1
      ~sources:[
        Patch "${PACKAGE}-${VERSION}.tar.bz2";
      ]
    in

    let _wineditline = add ("wineditline", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"2.101"
      ~build:1
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.bz2", "7943ffde32830adff5e70aec76da78899d1e20ae");
      ]
    in

    let _libcdio = add ("libcdio", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ _libcddb ]
      ~version:"0.83"
      ~build:1
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.xz", "dc03799b2ab878def5e0517d70f65a91538e9bc1");
      ]
    in

    let _miniupnpc = add ("miniupnpc", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"1.9"
      ~build:1
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.gz", "643001d52e322c52a7c9fdc8f31a7920f4619fc0");
      ]
    in

    add ("experimental", None)
      ~dir:""
      ~dependencies:[
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]

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

  let _download =
    (* fake package to reserve the name and make it known to the builder *)
    add ("download", None)
      ~dir:""
      ~dependencies:[]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]
  in

  let _disabled =
    let _vpnc = add ("vpnc", None)
      ~dir:"slackbuilds.org/network"
      ~dependencies:[ (* libogg *) ]
      ~version:"0.5.3"
      ~build:1
      ~sources:[
        Tarball ("${PACKAGE}-${VERSION}.tar.gz", "321527194e937371c83b5e7c38e46fca4f109304");
      ]
    in

    add ("disabled", None)
      ~dir:""
      ~dependencies:[]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]

  in

  ()

let () =
  List.iter do_adds Builders.Windows.[ builder_32; builder_64 ]
