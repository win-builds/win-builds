#!/bin/sh -e

if echo "${COMSPEC}" | grep -q 'SysWOW64'; then
  ARCHS=${1:-"i686 x86_64"}
else
  ARCHS=${1:-"i686"}
fi

case " ${ARCHS} " in
  *" i686 "*)   ;;
  *" x86_64 "*) ;;
  *) echo "Unknown arch \`${ARCH}' specificied. Aborting." 1>&2; exit 1 ;;
esac

CYG='grep ^CYGWIN /proc/version'

OLD_PATH="${PATH}"

mkdir -p /bin
cp yypkg.exe sherpa.exe win-builds-switch.sh /bin

for ARCH in ${ARCHS}; do
  case "${ARCH}" in
    "i686")   BITS="32" ;;
    "x86_64") BITS="64" ;;
    *) ;;
  esac

  YYPREFIX="/opt/windows_${BITS}"
  PANGO_CACHE="${YYPREFIX}/etc/pango/pango.modules"
  export PATH="${YYPREFIX}/bin:.:${OLD_PATH}"

  # On Cygwin we need to translate YYPREFIX explicitely; on msys it is
  # automatic.
  if ${CYG} >/dev/null 2>/dev/null; then
    export YYPREFIX="$(cygpath -m "${YYPREFIX}")"
  else
    export YYPREFIX
  fi

  echo "Installing win-builds for ${ARCH} in ${YYPREFIX}."
  yypkg -init
  yypkg -config -setpreds host="${ARCH}-w64-mingw32"
  yypkg -config -setpreds target="${ARCH}-w64-mingw32"
  sherpa -set-mirror "http://win-builds.org/@@VERSION@@/packages/windows_${BITS}"
  echo 'Downloading and installing packages.'
  sherpa -install all

  if yypkg -list | grep -q 'fontconfig'; then
    echo "Updating fontconfig's cache (this may take a while)."
    fc-cache
  fi
  if yypkg -list | grep -q 'pango'; then
    echo "Updating pango's module cache."
    # Pango doesn't respect --libdir for the module cache so simply update the
    # list in /etc (for now).
    pango-querymodules > ${PANGO_CACHE}
  fi
  if yypkg -list | grep -q 'gtk+'; then
    echo "Updating gdk's pixbuf cache."
    gdk-pixbuf-query-loaders --update-cache
    echo "Updating gtk's immodules cache."
    gtk-query-immodules-2.0 --update-cache
  fi
done

