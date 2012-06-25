#!/bin/bash -eux

LOCATION="${1}"

mkdir -p "${LOCATION}/packages" "${LOCATION}/logs"

LOCATION="$(cd "${LOCATION}" && pwd)"

BIND_MOUNTED_DIRS=""
SPECIAL_FILESYSTEMS=""

YYPKG_SRC="/home/adrien/projects/yypkg/src"
YYPKG_HST="${YYPKG_SRC}/yypkg.native"

BD_CONFIG="toolchain"

ARCH="x86_64"

if [ "${ARCH}" = "i486" ]; then
  YYPKG_TGT="${PWD}/i486/yypkg.native"
  MAKEYPKG_TGT="${PWD}/i486/makeypkg.native"
  BSDTAR_TGT="${PWD}/i486/bsdtar"
  FOO="/home/adrien/t/sbchroot/slackware-current/"
  LIBDIRSUFFIX=""
else
  YYPKG_TGT="${YYPKG_SRC}/yypkg.native"
  MAKEYPKG_TGT="${YYPKG_SRC}/makeypkg.native"
  BSDTAR_TGT="$(which bsdtar)"
  FOO="/"
  LIBDIRSUFFIX="64"
fi

YYOS_OUTPUT="/home/adrien/projects/yypkg_packages/yy_of_slack/tmp/output"
SYSTEM_COPY="${LOCATION}/system_copy"
SYSTEM="${LOCATION}/system"

LIB="lib${LIBDIRSUFFIX}"

mount_bind_ro() {
  old="$1"
  new="$2"
  mkdir -p "${new}"
  sudo mount --bind "${old}" "${new}"
  BIND_MOUNTED_DIRS="${new} ${BIND_MOUNTED_DIRS}"
  sudo mount -o remount,ro "${new}"
}

mount_dev_pts_and_procfs() {
  BASE="${1}"
  mkdir -p "${BASE}/proc" "${BASE}/dev/pts"
  sudo mount -t proc proc "${BASE}/proc"
  sudo mount -t devpts devpts "${BASE}/dev/pts"
  SPECIAL_FILESYSTEMS="${BASE}/proc ${BASE}/dev/pts ${SPECIAL_FILESYSTEMS}"
}

umounts() {
  if [ -n "${BIND_MOUNTED_DIRS}" -o -n "${SPECIAL_FILESYSTEMS}" ]; then
    sudo umount ${BIND_MOUNTED_DIRS} ${SPECIAL_FILESYSTEMS}
    BIND_MOUNTED_DIRS=""
    SPECIAL_FILESYSTEMS=""
  fi
}

populate_slash_dev() {
  mkdir ${SYSTEM_COPY}/dev
  sudo mkdir ${SYSTEM_COPY}/dev/pts
  sudo mknod ${SYSTEM_COPY}/dev/console c 5 1
  sudo mknod ${SYSTEM_COPY}/dev/null c 1 3
  sudo mknod ${SYSTEM_COPY}/dev/zero c 1 5
  sudo chmod 666 ${SYSTEM_COPY}/dev/null ${SYSTEM_COPY}/dev/zero
}

copy_ld_so() {
  ARCHIVE="$(find "${YYOS_OUTPUT}" -maxdepth 1 -name "glibc-2.*.txz" -printf '%f\n')"
  VER="$(echo "${ARCHIVE}" |sed -e 's/^glibc-\(2\.[0-9]\+\).*/\1/')"
  mkdir -p "${SYSTEM_COPY}/${LIB}"
  bsdtar xf "${YYOS_OUTPUT}/${ARCHIVE}" -q -C ${SYSTEM_COPY}/${LIB} \
    --strip-components=3 "package-glibc/${LIB}/incoming/ld-${VER}.so" 
  if [ ${ARCH} = "x86_64" ]; then
    ln -s ld-${VER}.so ${SYSTEM_COPY}/${LIB}/ld-linux-x86-64.so.2
  else
    ln -s ld-${VER}.so ${SYSTEM_COPY}/${LIB}/ld-linux.so.2
  fi
}

if [ ! -e "${SYSTEM}" ]; then
  INITDIR="/tmp/yypkg_init"
  INITDIR_FULL="${SYSTEM_COPY}/${INITDIR}"

  YYPREFIX="${SYSTEM_COPY}" "${YYPKG_HST}" -init

  mkdir -p ${INITDIR_FULL}/pkgs

  trap umounts EXIT SIGINT

  for dir in bin ${LIB} usr/${LIB}; do
    mount_bind_ro "${FOO}${dir}" "${INITDIR_FULL}/host/${dir}"
  done

  rsync --archive "${YYOS_OUTPUT}/" "${INITDIR_FULL}/pkgs/"

  populate_slash_dev

  copy_ld_so

  for bin in "${YYPKG_TGT}" "${MAKEYPKG_TGT}" "${BSDTAR_TGT}"; do
    bin_basename="$(basename "${bin}")"
    cp "${bin}" "${SYSTEM_COPY}/sbin/${bin_basename%.native}"
  done

  find "${INITDIR_FULL}/pkgs" -maxdepth 1 -name '*.txz' -printf '%f\n' \
    | while read PKG; do
      echo "Installing ${PKG}";
      sudo YYPREFIX="/" PATH="${INITDIR}/host/bin:${PATH}" LD_LIBRARY_PATH="${INITDIR}/host/${LIB}:${INITDIR}/host/usr/${LIB}" chroot "${SYSTEM_COPY}" "/sbin/yypkg" "-install" "${INITDIR}/pkgs/${PKG}" || true
  done

  for bin in cc c++ {${ARCH}-slackware-linux-,}{gcc,g++}; do
    ln -s "/usr/bin/ccache" "${SYSTEM_COPY}/usr/local/bin/${bin}"
  done

  umounts

  sudo cp -r --preserve="mode,timestamps" "${SYSTEM_COPY}" "${SYSTEM}"
fi

trap umounts EXIT SIGINT
mount_dev_pts_and_procfs "${SYSTEM}"

mkdir -p "${SYSTEM}/root/yypkg_packages"
cp build_daemon slackbuild_wrap build_daemon_config_{toolchain,libs} "${SYSTEM}/root/yypkg_packages"

sudo chroot "${SYSTEM}" "/bin/bash" "-c" "cd /root/yypkg_packages && ./build_daemon build_daemon_config_toolchain"

