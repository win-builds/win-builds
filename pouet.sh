#!/bin/bash

set -eux

# iter: wrap the creation and installation of exactly one package from a slackbuild
# It first runs the slackbuild, redirecting its output (stdout+stderr) to log, but
# only its stderr is printed on screen.
# It then installs the package
# $1: slackbuild to run (path)
# $2: package name
# $3: log file
function iter {
  echo Running $1
  sha1sum ${YYOUTPUT}/*.txz | sort > ${YYOUTPUT}/files_pre
  if echo "${1}" | grep -q "\.SlackBuild$"; then
    ( ( PKGNAM=$2 slackbuild_wrap $1 3>&1 1>&2 2>&3 ) | tee /dev/tty ) > $3 2>&1
  else
    ( ( "${1}" 3>&1 1>&2 2>&3 ) | tee /dev/tty ) > $3 2>&1
  fi
  sha1sum ${YYOUTPUT}/*.txz | sort > ${YYOUTPUT}/files_post
  comm -13 ${YYOUTPUT}/files_{pre,post} | awk '{ print $2; }' | xargs yypkg -upgrade -install-new
}

CWD="$PWD/$(dirname $0)"

export TRIPLET="i686-w64-mingw32"
export YYPREFIX=/$TRIPLET
export YYOUTPUT=/tmp/yypackages
export ARCH=x86_64
export BUILD="x86_64-slackware-linux"

if [ -e ${YYPREFIX} -o -e ${YYPREFIX} ]; then
  echo ${YYPREFIX} already exists. Please rm it. Aborting.
  exit 1
fi
mkdir -p ${YYPREFIX} ${YYOUTPUT} logs

yypkg -init

M="mingw-builds/mingws"
P="slackware64-current/slackware64-current/source"

#PKG=mingw-w64; iter ${M}/mingw-w64/mingw-w32_w64.sh ${PKG} logs/${PKG}-${TRIPLET}.log

(
  export TGT="${TRIPLET}"

  export HST="${BUILD}"
  PKG=binutils; iter ${P}/d/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log

  export HST="${TRIPLET}"
  PKG=mingw-w64-headers; iter ${M}/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log

  export HST="${BUILD}"
  PKG=gcc; iter ${P}/d/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log

  export HST="${TRIPLET}"
  PKG=mingw-w64-crt; iter ${M}/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log

  export HST="${BUILD}"
  PKG=gcc; iter ${P}/d/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log

exit 0

  export TGT="None"
  export HST="${TRIPLET}"

  PKG=iconv; iter ${M}/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=gettext; iter ${P}/a/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  #PKG=gettext-tools; iter ${P}/a/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log

  exit 0

  PKG=zlib; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=pcre; iter ${P}/l/${PKG}/$PKG.SlackBuild $PKG logs/${HST}-$PKG.log
  PKG=glib; iter ${P}/l/${PKG}2/${PKG}2.SlackBuild ${PKG} logs/${PKG}2-${HST}.log
  PKG=atk; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=libpng; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=pixman; iter ${P}/x/x11/pixman.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=cairo; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=pango; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  #PKG=poppler; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=expat; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=libtiff; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=libjpeg; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
  PKG=gdk-pixbuf; iter ${P}/l/${PKG}2/${PKG}2.SlackBuild ${PKG} logs/${PKG}2-${HST}.log
  PKG=gtk+2; iter ${P}/l/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log

  PKG=wget; iter ${P}/n/${PKG}/${PKG}.SlackBuild ${PKG} logs/${PKG}-${HST}.log
)

sherpa_gen ${YYOUTPUT} > ${YYOUTPUT}/repo
