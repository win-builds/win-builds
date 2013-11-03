#!/bin/sh -eu

for d in native_toolchain cross_toolchain_32 windows_32; do
  export YYPREFIX="/opt/${d}"

  echo "Initializing yypkg in ${YYPREFIX}."
  yypkg -init

  sherpa -set-mirror "http://win-builds.org/current/packages/${d}"

  echo "Setting up predicates for ${d}."
  if [ "${d}" = "cross_toolchain_32" ]; then
    yypkg -config -setpreds host="x86_64-slackware-linux"
    yypkg -config -setpreds target="i686-w64-mingw32"
  elif [ "${d}" = "windows_32" ]; then
    yypkg -config -setpreds host="i686-w64-mingw32"
  elif [ "${d}" = "native_toolchain" ]; then
    yypkg -config -setpreds host="x86_64-slackware-linux"
  fi

  echo "Downloading and installing packages for ${d}."
  sherpa -install 'all'
done
