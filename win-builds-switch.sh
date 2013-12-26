#!/bin/awk /^#_/ { print gensub("^#_", "", "1") } END { exit 1 }
# The shebang above will display the message below for people who run the
# script in a new shell instead of sourcing it in their current shell.

#_!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#_
#_  ERROR!
#_
#_  This script is being executed in a separate shell while it has to execute
#_  in an already existing one.
#_
#_  This means you have started this script as "win-builds-switch 64" (or 32)
#_  while you need to prepend ". " in front of that command for it to be
#_  effective:
#_    . win-builds-switch 64
#_
#_  (and before you ask, while your mistake has been noticed automatically, it
#_  cannot be corrected automatically)
#_
#_!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

case "$1" in
  "32") BITS="$1"; LIBDIRSUFFIX="" ;;
  "64") BITS="$1"; LIBDIRSUFFIX="64";;
  *) ;;
esac

CYG='grep ^CYGWIN /proc/version'

if [ -n "${BITS}" ]; then
  YYPREFIX="/opt/windows_${BITS}"
  YYPATH="${YYPREFIX}/bin"
  if [ ! -d "${YYPATH}" ]; then
    echo "The ${YYPATH} directory doesn't exist; there cannot be a valid setup there." 1>&2
    exit
  fi
  if ${CYG} >/dev/null 2>/dev/null; then
    case ":${PATH}:" in
      *:/opt/windows_??/bin:*)
        PATH="$(echo "${PATH}" | sed "s;/opt/windows_../bin;${YYPATH};g")" ;;
      *) PATH="${YYPATH}:${PATH}" ;;
    esac
    export PATH
  fi
  export YYPREFIX
  export PKG_CONFIG_LIBDIR="${YYPREFIX}/lib${LIBDIRSUFFIX}/pkgconfig"
else
  echo 'You must either specify "32" or "64" on the command-line.' 1>&2
  false
fi
