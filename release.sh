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

mkdir "${DEST}" "${DEST}/packages" "${DEST}/logs"

cp "${LOCATION}/system.tar.xz" "${DEST}"

find "${LOCATION}/packages" -mindepth 1 -maxdepth 1 -type d -printf '%P\n' \
  | while read REPO; do
      echo "Setting up ${REPO}."
      for d in logs packages; do 
        cp -a "${LOCATION}/${d}/${REPO}" "${DEST}/${d}/${REPO}"
      done
      "${SHERPA_GEN}" "${DEST}/packages/${REPO}"
    done
