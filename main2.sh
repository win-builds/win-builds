#!/bin/sh -eux

LOCATION="${1}"
KIND="${2:-"init-toolchain-libs"}"

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

  echo "Building ${PKG}${VARIANT}."

  if [ -d "${PKG_PATH}" ]; then
    sudo tar cf "${YYPKG_PACKAGES}/${PKG}${VARIANT}.tar" \
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
  sudo touch "${YYPKG_PACKAGES}/exit-build-daemon"
  sleep 4
}

start_build_daemon() {
  (cd mingw-builds && sudo ./main.sh "${LOCATION}" "${1}") &
  trap exit_build_daemon EXIT SIGINT ERR
  sleep 4
}

if echo "${KIND}" | grep -q init && ! [ -d "${LOCATION}/system" ]; then
  sudo ./mingw-builds/main.sh "${LOCATION}" "whatever"
fi

if echo "${KIND}" | grep -q toolchain; then
  start_build_daemon "toolchain"
  queue_cond slackware64-current/d/binutils ""
  queue_cond mingw/mingw-w64 "headers"
  queue_cond slackware64-current/d/gcc "core"
  queue_cond mingw/mingw-w64 "full"
  queue_cond slackware64-current/d/gcc "full"
  exit_build_daemon
  wait
fi

if echo "${KIND}" | grep -q libs; then
  start_build_daemon "libs"
  queue_cond slackware64-current/a/xz ""
  queue_cond mingw/win-iconv ""
  queue_cond slackware64-current/a/gettext ""
  queue_cond slackware64-current/l/zlib ""
  queue_cond slackware64-current/l/libjpeg ""
  queue_cond slackware64-current/l/expat ""
  queue_cond slackware64-current/l/freetype ""
  queue_cond slackware64-current/x/fontconfig "" # depends on expat, freetype
  queue_cond slackware64-current/l/libpng ""
  queue_cond slackbuilds.org/lua ""
  exit_build_daemon
  wait
fi

