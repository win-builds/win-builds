#!/bin/sh -e

if echo "${COMSPEC}" | grep -q 'SysWOW64'; then
  ARCHS=${1:-"i686 x86_64"}
else
  ARCHS=${1:-"i686"}
fi

for ARCH in ${ARCHS}; do
  case "${ARCH}" in
    "i686")   BITS="32" ;;
    "x86_64") BITS="64" ;;
    *) ;;
  esac
  if cygpath --help 2>/dev/null >/dev/null; then
    export YYPREFIX="$(cygpath -m "/opt/windows_${BITS}")"
  else
    export YYPREFIX="/opt/windows_${BITS}"
  fi
  echo "Installing win-builds for ${ARCH} in ${YYPREFIX}."
  yypkg -init
  yypkg -config -setpreds host="${ARCH}-w64-mingw32"
  yypkg -config -setpreds target="${ARCH}-w64-mingw32"
  sherpa -set-mirror "http://win-builds.org/1.3-rc1/packages/windows_${BITS}"
  sherpa -install all
done

mkdir -p /bin
cp yypkg.exe sherpa.exe win-builds-switch.sh /bin
