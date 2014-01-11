#!/bin/sh -e

CYG='grep ^CYGWIN /proc/version'

if $CYG >/dev/null 2>/dev/null; then
  echo "Cygwin detected."

  if grep -q -e 'WOW64' -e 'x86_64' '/proc/version'; then
    ARCHS=${1:-"i686 x86_64"}
  else
    ARCHS=${1:-"i686"}
  fi
else
  echo "Msys detected."

  if echo "${COMSPEC}" | grep -q 'SysWOW64'; then
    ARCHS=${1:-"i686 x86_64"}
  else
    ARCHS=${1:-"i686"}
  fi
fi

case " ${ARCHS} " in
  *" i686 "*)   ;;
  *" x86_64 "*) ;;
  *) echo "Unknown arch \`${ARCHS}' specificied. Aborting." 1>&2; exit 1 ;;
esac

echo "Installing for $(echo ${ARCHS} | sed 's/ / and /')."

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

  echo "*************************************************"
  echo "Installing win-builds for ${ARCH} in ${YYPREFIX}."
  echo "*************************************************"

  yypkg -init
  yypkg -config -setpreds host="${ARCH}-w64-mingw32"
  yypkg -config -setpreds target="${ARCH}-w64-mingw32"
  sherpa -set-mirror "http://win-builds.org/@@VERSION@@/packages/windows_${BITS}"
  echo 'Downloading and installing packages.'
  sherpa -install all

  if yypkg -list | grep -q 'fontconfig'; then
    echo "Updating fontconfig's cache (takes lot of time and memory on Windows >= 7)."
    fc-cache
  fi
  if yypkg -list | grep -q 'pango'; then
    echo "Updating pango's module cache."
    # Pango doesn't respect --libdir for the module cache so simply update the
    # list in /etc (for now).
    pango-querymodules > ${PANGO_CACHE}
  fi
  if yypkg -list | grep -q 'gtk+'; then
    if ! grep -q '^CYGWIN_NT-5' '/proc/version'; then
      echo "Updating gdk's pixbuf cache."
      gdk-pixbuf-query-loaders --update-cache
    else
      echo "Updating gdk's pixbuf cache..; IMPOSSIBLE on Cygwin on XP/2k3!"
      echo "Please run 'gdk-pixbuf-query-loaders --update-cache' from a new cmd.exe."
    fi
    echo "Updating gtk's immodules cache."
    gtk-query-immodules-2.0 --update-cache
  fi
done

cat << EOF
Win-builds has been installed for $(echo ${ARCHS} | sed 's/ / and /').
However no setting has been changed on the computer.
Remember to select a environment as described at http://win-builds.org/@@VERSION@@/msys-cygwin.html .
EOF

