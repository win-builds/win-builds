#!/bin/sh -eux

LOCATION="${1}"
LOCATION="$(cd "${1}" && pwd)"
YYPKG_PACKAGES="${LOCATION}/system/root/yypkg_packages"

cd /home/adrien/projects/yypkg_packages

queue() {
  PKG_PATH="${1}"
  if [ -n "${2}" ]; then
    VARIANT="-${2}"
  else
    VARIANT=""
  fi

  PKG="$(basename "${PKG_PATH}")"

  echo "Building ${PKG}${VARIANT}."

  sudo tar cf "${YYPKG_PACKAGES}/${PKG}${VARIANT}.tar" \
    --transform="s/config${VARIANT}/config/" \
    --transform="s/${PKG}.SlackBuild/${PKG}${VARIANT}.SlackBuild/" \
    -C "${PKG_PATH}" .
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

