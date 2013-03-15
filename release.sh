#!/bin/sh -eux

DEST="${1}"
LOCATION="${2}"
LOCATION="$(cd "${LOCATION}" && pwd)"

CWD="$(pwd)"

SHERPA_GEN="${CWD}/yypkg/src/sherpa_gen.native"

if [ -d "${DEST}" ]; then
  echo "Directory ${DEST} not empty."
  exit 1
fi

mkdir "${DEST}" "${DEST}/packages"

cp "${LOCATION}/system.tar.xz" "${DEST}"

for REPO in $(find "${LOCATION}/packages" -mindepth 1 -maxdepth 1 -type d -printf '%P\n'); do
  echo "Setting up ${REPO}"
  cp -a "${LOCATION}/packages/${REPO}" "${DEST}/packages/${REPO}"
  "${SHERPA_GEN}" "${DEST}/packages/${REPO}"
done
