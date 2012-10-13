#!/bin/sh -eu

for d in cross_toolchain_32 windows_32; do
  export YYPREFIX="/opt/${d}"

  echo "Initializing yypkg in ${YYPREFIX}."
  yypkg -init

  sed -i "s/SERIES/${d}/" "${YYPREFIX}/etc/yypkg.d/sherpa.conf"

  echo "Setting up predicates for ${d}."
  if [ "${d}" = "cross_toolchain_32" ]; then
    yypkg -config -setpreds host="x86_64-slackware-linux"
    yypkg -config -setpreds target="i686-w64-mingw32"
  else if [ "${d}" = "windows_32" ]; then
    yypkg -config -setpreds host="i686-w64-mingw32"
  fi; fi

  echo "Downloading and installing packages for ${d}."
  sherpa -install '*'
done
