#!/bin/sh -eux

LOCATION="${1}"
KIND="${2:-"init-cross_toolchain_32-windows_32"}"

if [ $# -ge 3 ]; then
  shift
  shift
  PKG_LIST=$*
else
  PKG_LIST=""
fi


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

if echo "${KIND}" | grep -q init && ! [ -d "${LOCATION}/system" ]; then
  ./mingw-builds/main.sh "${LOCATION}" "whatever"
fi

SBo="slackbuilds.org"
SLACK="slackware64-current"

if echo "${KIND}" | grep -q cross_toolchain_32; then
  start_build_daemon "cross_toolchain_32"
  queue_cond ${SLACK}/d/binutils ""
  queue_cond mingw/mingw-w64 "headers"
  queue_cond ${SLACK}/d/gcc "core"
  queue_cond mingw/mingw-w64 "full"
  queue_cond ${SLACK}/d/gcc "full"
  exit_build_daemon
  wait
fi

if echo "${KIND}" | grep -q windows_32; then
  start_build_daemon "windows_32"
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
  queue_cond ${SLACK}/l/mpfr ""
  queue_cond ${SLACK}/l/libmpc ""
  # queue_cond ${SLACK}/d/gcc "full"
  # queue_cond ${SLACK}/xap/gucharmap "" # requires GTK+-3
  # queue_cond ${SLACK}/xap/geeqie "" # includes <pwd.h>
  exit_build_daemon
  wait
fi

