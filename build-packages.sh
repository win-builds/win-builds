#!/bin/sh -eu

TRIPLET="${TRIPLET:-i686-w64-mingw32}"
case "${TRIPLET}" in
  i686-w64-mingw*) BITS="32";;
  x86_64-w64-mingw*) BITS="64";;
esac

NATIVE_TOOLCHAIN="native_toolchain"
CROSS_TOOLCHAIN="cross_toolchain_${BITS}"
WINDOWS="windows_${BITS}"

DEFAULT_KIND="init-${NATIVE_TOOLCHAIN}-${CROSS_TOOLCHAIN}-${WINDOWS}"

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

umask 022

mkdir -p "${LOCATION}"
LOCATION="$(cd "${LOCATION}" && pwd)"
YYPKG_PACKAGES="${LOCATION}/system/root/yypkg_packages"

queue() {
  PKG_PATH="${1}"
  VARIANT="${2}"

  PKG="$(basename "${PKG_PATH}")"

  echo "Sending ${PKG}${VARIANT}."

  if [ -d "${PKG_PATH}" ]; then
    tar cf "${YYPKG_PACKAGES}/${PKG}${VARIANT}.tar" \
      --transform="s/config${VARIANT}/config/" \
      --transform="s/${PKG}.SlackBuild/${PKG}${VARIANT}.SlackBuild/" \
      -C "${PKG_PATH}" .
  else
    return 1
  fi
}

queue_cond() {
  PKG_PATH="${1}"
  if [ -n "${2}" ]; then
    VARIANT="-${2}"
  else
    VARIANT=""
  fi

  PKG="$(basename "${PKG_PATH}")"

  if [ -z "${PKG_LIST}" ] || echo ${PKG_LIST} | grep -q "${PKG}${VARIANT}"; then
    queue "${PKG_PATH}" "${VARIANT}"
  fi
}

exit_build_daemon() {
  touch "${YYPKG_PACKAGES}/exit-build-daemon"
  sleep 4
}

start_build_daemon() {
  (cd mingw-builds && ./main.sh "${LOCATION}" "${1}" "yes") &
  trap exit_build_daemon EXIT SIGINT ERR
  sleep 4
}

enable_ccache() {
  for bin in ${TRIPLET}-{gcc,g++}; do
    ln -sf "/usr/bin/ccache" "${LOCATION}/system/usr/local/bin/${bin}"
  done
}

if echo "${KIND}" | grep -q init && ! [ -d "${LOCATION}/system" ]; then
  ./mingw-builds/main.sh "${LOCATION}" "whatever"
fi

SBo="slackbuilds.org"
SLACK="slackware64-current"

enable_ccache

if echo "${KIND}" | grep -q ${NATIVE_TOOLCHAIN}; then
  start_build_daemon "${NATIVE_TOOLCHAIN}"
  queue_cond ${SBo}/ocaml ""
  exit_build_daemon
  wait
fi

if echo "${KIND}" | grep -q ${CROSS_TOOLCHAIN}; then
  start_build_daemon "${CROSS_TOOLCHAIN}"
  queue_cond ${SLACK}/d/binutils ""
  queue_cond mingw/mingw-w64 "headers"
  queue_cond ${SLACK}/d/gcc "core"
  queue_cond mingw/mingw-w64 "full"
  queue_cond ${SLACK}/d/gcc "full"
  queue_cond mingw/flexdll ""
  exit_build_daemon
  wait
fi

if echo "${KIND}" | grep -q ${WINDOWS}; then
  start_build_daemon "${WINDOWS}"
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
  for efl_lib in evil eina eet evas ecore embryo edje; do
    queue_cond ${SBo}/${efl_lib} ""
  done
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
  # queue_cond ${SLACK}/l/sdl "base"
  # queue_cond ${SLACK}/l/sdl "others"
  # queue_cond ${SBo}/webkit-gtk ""
  # queue_cond ${SLACK}/xap/gucharmap "" # requires GTK+-3
  # queue_cond ${SLACK}/xap/geeqie "" # includes <pwd.h>

  # Mozilla crap, I'll deal with that later, if ever
  # queue_cond mingw/nspr ""
  # queue_cond ${SLACK}/l/mozilla-nss ""
  exit_build_daemon
  wait
fi

for d in "packages" "logs"; do
  mkdir -p "${LOCATION}/${d}"
  rsync --verbose --archive --delete-after --progress "${YYPKG_PACKAGES}/${d}/" "${LOCATION}/${d}/"
done
