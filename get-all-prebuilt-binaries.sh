#!/bin/sh -eu

setup() {
  D="${1}"

  export YYPREFIX="/opt/${D}"

  echo "Initializing yypkg in ${YYPREFIX}."
  yypkg -init

  sherpa -set-mirror "http://win-builds.org/@@VERSION@@/packages/${D}"

  echo "Setting up predicates for ${D}."
  case "${D}" in
    "native_toolchain")
        yypkg -config -setpreds host="x86_64-slackware-linux"
      ;;
    "cross_toolchain_32")
        yypkg -config -setpreds host="x86_64-slackware-linux"
        yypkg -config -setpreds target="i686-w64-mingw32"
      ;;
    "cross_toolchain_64")
        yypkg -config -setpreds host="x86_64-slackware-linux"
        yypkg -config -setpreds target="x86_64-w64-mingw32"
      ;;
    "windows_32")
        yypkg -config -setpreds host="i686-w64-mingw32"
      ;;
    "windows_64")
        yypkg -config -setpreds host="x86_64-w64-mingw32"
      ;;
  esac

  echo "Downloading and installing packages for ${D}."
  sherpa -install 'all'
}

setup native_toolchain
for kind in cross_toolchain windows; do
  for bits in 32 64; do
    setup "${kind}_${bits}"
  done
done
