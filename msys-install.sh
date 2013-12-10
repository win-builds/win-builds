#!/bin/sh -e

ARCHS=${1:-"i686 x86_64"}

for ARCH in ${ARCHS}; do
  case "${ARCH}" in
    "i686")   BITS="32" ;;
    "x86_64") BITS="64" ;;
    *) ;;
  esac
  echo "Installing win-builds for ${ARCH} in /opt/win_builds_${BITS}."
  export YYPREFIX="/c/win_builds/msys/1.0/opt/windows_${BITS}"
  yypkg -init
  yypkg -config -setpreds host="${ARCH}-w64-mingw32"
  yypkg -config -setpreds target="${ARCH}-w64-mingw32"
  sherpa -set-mirror "http://win-builds.org/1.3-beta3/packages/windows_${BITS}"
  sherpa -install all
done

mkdir -p /sbin
cp yypkg.exe sherpa.exe win-builds-switch.sh /bin
