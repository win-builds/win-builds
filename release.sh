#!/bin/sh -eu

LOCATION="${1}"
LOCATION="$(cd "${LOCATION}" && pwd)"

CWD="$(pwd)"

MIRROR="notk.org:/var/www/yypkg.org/latest/packages"
SHERPA_GEN="${CWD}/yypkg/src/sherpa_gen.native"

mkdir -p "${LOCATION}/repositories"

rsync -avzP "${LOCATION}/system.tar.xz" "${MIRROR}/"

for REPO in $(find "${LOCATION}/packages" -mindepth 1 -maxdepth 1 -type d); do
  echo "Setting up ${REPO}"
  REPO_NAME="$(basename "${REPO}")"
  OUTPUT="${LOCATION}/repositories/${REPO_NAME}"
  mkdir -p "${OUTPUT}"
  "${SHERPA_GEN}" "${REPO}" "${OUTPUT}"
  rsync -avzP "${REPO}" "${MIRROR}/"
  rsync -avzP --exclude='memo_*' "${OUTPUT}/" "${MIRROR}/${REPO_NAME}/"
done
