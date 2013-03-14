#!/bin/sh -eu

DEST="${1}"
LOCATION="${2}"
LOCATION="$(cd "${LOCATION}" && pwd)"

CWD="$(pwd)"

SHERPA_GEN="${CWD}/yypkg/src/sherpa_gen.native"

mkdir -p "${DEST}"

cp "${LOCATION}/system.tar.xz" "${DEST}"

for REPO in $(find "${LOCATION}/packages" -mindepth 1 -maxdepth 1 -type d -printf '%P\n'); do
  echo "Setting up ${REPO}"
  cp -a "${REPO}" "${DEST}/${REPO}"
  "${SHERPA_GEN}" "${DEST}/${REPO}"
done
