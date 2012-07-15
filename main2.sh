#!/bin/sh -eux

LOCATION="${1}"
KIND="${2:-"both"}"
shift
shift
PKG_LIST=$*

LOCATION="$(cd "${LOCATION}" && pwd)"
YYPKG_PACKAGES="${LOCATION}/system/root/yypkg_packages"

cd /home/adrien/projects/yypkg_packages

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

queue slackware64-current/d/binutils ""
exit_build_daemon() {
  sudo touch "${YYPKG_PACKAGES}/exit-build-daemon"
  sleep 4
}

queue mingw/mingw-w64 "headers"
 
queue slackware64-current/d/gcc "core"
start_build_daemon() {
  (cd mingw-builds && sudo ./main.sh "${LOCATION}" "${1}") &
  trap exit_build_daemon EXIT SIGINT ERR
  sleep 4
}

queue mingw/mingw-w64 "full"

queue slackware64-current/d/gcc "full"

