#!/bin/sh

for d in cross_toolchain_32 windows_32; do
  yypkg -prefix /opt/${d} -init
  sed -i "s/SERIES/${d}/" /opt/${d}/etc/yypkg.d/sherpa.conf
  if [ "${d}" = "cross_toolchain_32" ]; then
    yypkg -config -setpreds host="x86_64-slackware-linux"
    yypkg -config -setpreds target="i686-w64-mingw32"
  else if [ "${d}" = "windows_32" ]; then
    yypkg -config -setpreds host="i686-w64-mingw32"
  fi; fi
  sherpa -prefix /opt/${d} -install '*'
done
