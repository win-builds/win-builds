#!/bin/sh -e

if echo "${COMSPEC}" | grep -q 'SysWOW64'; then
  ARCHS=${1:-"i686 x86_64"}
else
  ARCHS=${1:-"i686"}
fi

CYG='grep ^CYGWIN /proc/version'

OLD_PATH="${PATH}"

for ARCH in ${ARCHS}; do
  case "${ARCH}" in
    "i686")   BITS="32" ;;
    "x86_64") BITS="64" ;;
    *) ;;
  esac
  if ${CYG} >/dev/null 2>/dev/null; then
    export YYPREFIX="$(cygpath -m "/opt/windows_${BITS}")"
  else
    export YYPREFIX="/opt/windows_${BITS}"
  fi

  export PATH="${YYPREFIX}/bin:${OLD_PATH}"

  echo "Installing win-builds for ${ARCH} in ${YYPREFIX}."
  ./yypkg -init
  ./yypkg -config -setpreds host="${ARCH}-w64-mingw32"
  ./yypkg -config -setpreds target="${ARCH}-w64-mingw32"
  ./sherpa -set-mirror "http://win-builds.org/@@VERSION@@/packages/windows_${BITS}"
  echo 'Downloading and installing packages.'
  ./sherpa -install all

  echo 'Updating GDK, GTK, Pango and font caches (this may take a while).'
  gdk-pixbuf-query-loaders --update-cache
  gtk-query-immodules-2.0 --update-cache
  pango-querymodules --update-cache
  fc-cache
done

mkdir -p /bin
cp yypkg.exe sherpa.exe win-builds-switch.sh /bin
