#!/bin/sh -eu

LOCATION="${1}"
LOCATION="$(cd "${LOCATION}" && pwd)"

MIRROR="notk.org:public_html/yypkg/latest/packages"
SHERPA_GEN="${HOME}/projects/yypkg/src/sherpa_gen.native"

mkdir -p "${LOCATION}/repositories"

repos="$(find "${LOCATION}/packages" -mindepth 1 -maxdepth 1 -type d)"

for REPO in ${repos}; do
  echo "Setting up ${REPO}"
  REPO_NAME="$(basename "${REPO}")"
  OUTPUT="${LOCATION}/repositories/${REPO_NAME}"
  mkdir -p "${OUTPUT}"
  "${SHERPA_GEN}" "${REPO}" "${OUTPUT}"
  rsync --progress --archive --exclude="memo_*" "${OUTPUT}/" "${MIRROR}/${REPO_NAME}/"
done
