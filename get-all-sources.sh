#!/bin/sh -eu

SLACKWARE_SOURCE="mirror/slackware64-current/source"
MIRROR="http://notk.org/~adrien/yypkg/latest/sources"

get() {
  FILE="${1}"
  echo "Downloading ${FILE}."
  wget -c "${FILE}"
}

lftp -c "connect ${MIRROR}/slackware64-current; mirror slackware64-current"
lftp -c "connect ${MIRROR}/slackbuilds.org; mirror slackbuilds.org"
lftp -c "connect ${MIRROR}/mingw; mirror mingw"

