#!/bin/sh

case "$1" in
  "32") BITS="$1"; LIBDIRSUFFIX="" ;;
  "64") BITS="$1"; LIBDIRSUFFIX="64";;
  *) ;;
esac

if [ -n "${BITS}" ]; then
  YYPREFIX="/opt/windows_${BITS}"
  YYPATH="${YYPREFIX}/bin"
  if [ ! -d "${YYPATH}" ]; then
    echo "The ${YYPATH} directory doesn't exist; there cannot be a valid setup there." 1>&2
    exit
  fi
  case ":${PATH}:" in
    *:/opt/windows_??/bin:*)
      PATH="$(echo "${PATH}" | sed "s;/opt/windows_../bin;${YYPATH};g")" ;;
    *) PATH="${YYPATH}:${PATH}" ;;
  esac
  export YYPREFIX
  export PATH
  export PKG_CONFIG_LIBDIR="${YYPREFIX}/lib${LIBDIRSUFFIX}/pkgconfig"
else
  echo 'You must either specify "32" or "64" on the command-line.' 1>&2
  false
fi
