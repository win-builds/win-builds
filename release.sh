#!/bin/sh -eux

DEST="${1}"
LOCATION="${2}"
LOCATION="$(cd "${LOCATION}" && pwd)"

CWD="$(pwd)"

SHERPA_GEN="${CWD}/yypkg/src/sherpa_gen.native"

for d in "packages" "logs"; do
  echo "Copying ${d}."
  rsync -avP --delete-after --exclude='memo_*' "${LOCATION}/${d}/" "${DEST}/${d}/"
done

find "${DEST}/packages" -mindepth 1 -maxdepth 1 -type d -printf '%P\n' \
  | while read REPO; do
      echo "Setting up ${REPO}."
      "${SHERPA_GEN}" "${DEST}/packages/${REPO}"
    done
