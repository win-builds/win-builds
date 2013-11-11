#!/bin/sh -eu

TRIPLET="${TRIPLET:-i686-w64-mingw32}"
case "${TRIPLET}" in
  i686*)   BITS="32";;
  x86_64*) BITS="64";;
esac

DEFAULT_KIND="init-native_toolchain-cross_toolchain-windows"

LOCATION="${1}"
KIND="${2:-"${DEFAULT_KIND}"}"

if [ $# -ge 3 ]; then
  shift
  shift
  PKG_LIST=$*
else
  PKG_LIST=""
fi

if [ x"${KIND}" = x"${DEFAULT_KIND}" -a -z "${PKG_LIST}" ]; then
  echo "Warning. Going to build everything. This will take a while."
  echo "You have 10 seconds to cancel."
  sleep 10
fi

echo "Building packages with TRIPLET=${TRIPLET}."

umask 022

mkdir -p "${LOCATION}"
LOCATION="$(cd "${LOCATION}" && pwd)"
YYPKG_PACKAGES="${LOCATION}/system/root/yypkg_packages"
SHERPA_GEN="${PWD}/yypkg/src/sherpa_gen.native"

QUEUED_PACKAGES=""

queue_cond() {
  local PKG_PATH="${1}"
  local VARIANT="${2:+-${2}}"

  local PKG="${PKG_PATH##*/}"

  case " ${PKG_LIST} " in
    "  "|*" ${PKG}${VARIANT} "*)
      echo "Copying ${PKG}${VARIANT}."

      mkdir -p "${YYPKG_PACKAGES}"
      tar cf "${YYPKG_PACKAGES}/${PKG}${VARIANT}.tar" \
        --transform="s/config${VARIANT}/config/" \
        --transform="s/${PKG}.SlackBuild/${PKG}${VARIANT}.SlackBuild/" \
        -C "${PKG_PATH}" .

      QUEUED_PACKAGES="${QUEUED_PACKAGES} ${PKG}${VARIANT}.tar" ;;
  esac
}

copy_from_system() {
  local DIR="${1}"

  echo "Copying ${DIR}."

  rsync -avP --delete-after --exclude='memo_*' \
    "${YYPKG_PACKAGES}/${DIR}/" "${LOCATION}/${DIR}/"
}

build() {
  local KIND="${1}"

  if [ -n "${QUEUED_PACKAGES}" ]; then
    (cd win-builds && ./main.sh "${LOCATION}" "${KIND}" "yes" ${QUEUED_PACKAGES})

    case "${KIND}" in
      "native") local KIND_DIR="${KIND}" ;;
      *)        local KIND_DIR="${KIND%%-*-*-*}_${BITS}" ;;
    esac

    copy_from_system "logs/${KIND_DIR}"
    copy_from_system "packages/${KIND_DIR}"

    echo "Setting up ${KIND_DIR}."
    "${SHERPA_GEN}" "${LOCATION}/packages/${KIND_DIR}"
  fi
}

SBo="slackbuilds.org"
SLACK="slackware64-current"

if echo "${KIND}" | grep -q "native_toolchain"; then
  QUEUED_PACKAGES=""
  queue_cond ${SBo}/ocaml ""
  queue_cond ${SBo}/ocaml-findlib ""
  queue_cond ${SBo}/lua ""
  for efl_lib in eina eet evas ecore embryo edje; do
    queue_cond ${SBo}/${efl_lib} ""
  done
  build "native_toolchain"
fi

if echo "${KIND}" | grep -q "cross_toolchain"; then
  QUEUED_PACKAGES=""
  queue_cond ${SLACK}/d/binutils ""
  queue_cond mingw/mingw-w64 "headers"
  queue_cond ${SLACK}/d/gcc "core"
  queue_cond mingw/mingw-w64 "full"
  queue_cond ${SLACK}/d/gcc "full"
  queue_cond mingw/flexdll ""
  queue_cond ${SBo}/ocaml ""
  build "cross_toolchain-${TRIPLET}"

  for X in gcc g++; do
    ln -sf "/usr/bin/ccache" "${LOCATION}/system/usr/local/bin/${TRIPLET}-${X}"
  done
fi

if echo "${KIND}" | grep -q "windows"; then
  QUEUED_PACKAGES=""
  queue_cond ${SLACK}/l/libarchive "yypkg"
  queue_cond ${SLACK}/n/wget "yypkg"
  queue_cond mingw/win-iconv ""
  queue_cond ${SLACK}/a/gettext ""
  queue_cond ${SLACK}/a/xz ""
  queue_cond ${SLACK}/l/zlib ""
  queue_cond ${SLACK}/l/libjpeg ""
  queue_cond ${SLACK}/l/expat ""
  queue_cond ${SLACK}/l/freetype ""
  queue_cond ${SLACK}/x/fontconfig "" # depends on expat, freetype
  queue_cond ${SLACK}/l/libpng ""
  queue_cond ${SLACK}/l/giflib ""
  queue_cond ${SLACK}/l/libtiff ""
  queue_cond ${SBo}/lua ""
  queue_cond ${SLACK}/n/ca-certificates ""
  queue_cond ${SLACK}/n/curl ""
  queue_cond ${SBo}/c-ares ""
  queue_cond mingw/pixman ""
  queue_cond ${SLACK}/l/libffi ""
  queue_cond ${SLACK}/l/glib2 ""
  queue_cond ${SLACK}/l/cairo ""
  queue_cond ${SLACK}/l/atk ""
  queue_cond ${SLACK}/l/pango ""
  queue_cond ${SLACK}/l/gdk-pixbuf2 ""
  queue_cond ${SLACK}/l/gtk+2 ""
  queue_cond ${SLACK}/l/gmp ""
  queue_cond ${SLACK}/n/nettle ""
  queue_cond ${SLACK}/n/gnutls ""
  queue_cond ${SLACK}/l/glib-networking ""
  queue_cond ${SLACK}/l/libxml2 ""
  queue_cond ${SLACK}/ap/sqlite ""
  queue_cond ${SLACK}/l/libsoup ""
  queue_cond ${SLACK}/l/icu4c ""
  queue_cond ${SLACK}/d/gperf ""
  queue_cond ${SLACK}/l/libxslt ""
  queue_cond ${SLACK}/l/mpfr ""
  queue_cond ${SLACK}/l/libmpc ""
  queue_cond mingw/mingw-w64 "full"
  queue_cond ${SLACK}/d/binutils ""
  queue_cond ${SLACK}/d/gcc "full"
  queue_cond ${SLACK}/n/openssl ""
  queue_cond ${SLACK}/l/libogg ""
  queue_cond ${SLACK}/l/libvorbis ""
  queue_cond ${SLACK}/l/libtheora ""
  for efl_lib in evil eina eet evas ecore embryo edje elementary; do
    queue_cond ${SBo}/${efl_lib} ""
  done
  queue_cond ${SLACK}/d/pkg-config ""
  queue_cond ${SLACK}/l/libarchive "full"
  queue_cond ${SLACK}/n/wget "full"
  queue_cond ${SLACK}/l/sdl "base"
  queue_cond ${SLACK}/l/sdl "image"
  # queue_cond ${SLACK}/l/sdl "mixer"
  queue_cond ${SLACK}/l/sdl "net"
  # queue_cond ${SLACK}/l/sdl "ttf"
  # queue_cond ${SBo}/webkit-gtk ""
  # queue_cond ${SLACK}/xap/gucharmap "" # requires GTK+-3
  # queue_cond ${SLACK}/xap/geeqie "" # includes <pwd.h>

  # Mozilla crap, I'll deal with that later, if ever
  # queue_cond mingw/nspr ""
  # queue_cond ${SLACK}/l/mozilla-nss ""
  build "windows-${TRIPLET}"
fi
