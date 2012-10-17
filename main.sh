#!/bin/bash -eu

LOCATION="${1}" # Work directory
BD_CONFIG="${2:-"windows_32"}" # What to build?
BD="${3:-"no"}" # If "no", start a shell instead of build-daemon

# The architecture of the system inside the chroot
ARCH=${ARCH:-"x86_64"}

CWD="$(pwd)"

SOURCE_PATH="$(cd "$(dirname "${0}")" && pwd)"

umask 022

mkdir -p "${LOCATION}"
LOCATION="$(cd "${LOCATION}" && pwd)"

SYSTEM="${LOCATION}/system"

# The script mounts several filesystems; these variables keep track of what is
# mounted in order to always umount everything on exit
SPECIAL_FILESYSTEMS=""

if [ "${ARCH}" = "i486" ]; then
  LIB="lib"
else
  LIB="lib64"
fi

mount_dev_pts_and_procfs() {
  BASE="${1}"
  mkdir -p "${BASE}/proc" "${BASE}/dev/pts"
  mount -t proc proc "${BASE}/proc"
  SPECIAL_FILESYSTEMS="${BASE}/proc ${SPECIAL_FILESYSTEMS}"
  mount -t devpts devpts "${BASE}/dev/pts"
  SPECIAL_FILESYSTEMS="${BASE}/dev/pts ${SPECIAL_FILESYSTEMS}"
}

umounts() {
  if [ -n "${SPECIAL_FILESYSTEMS}" ]; then
    umount ${SPECIAL_FILESYSTEMS}
    SPECIAL_FILESYSTEMS=""
  fi
}

# Build the cross-compiler host system if ${SYSTEM} doesn't exist
if [ ! -e "${SYSTEM}" ]; then
  YYPKG_SRC="$(cd "${SOURCE_PATH}/../yypkg/" && pwd)"

  ARCH="${ARCH}" LIB="${LIB}" CWD="${CWD}" YYPKG_SRC="${YYPKG_SRC}" \
  SYSTEM="${SYSTEM}" SOURCE_PATH="${SOURCE_PATH}" \
  sh ${SOURCE_PATH}/host-system-init.sh
else
  trap umounts EXIT SIGINT ERR
  mount_dev_pts_and_procfs "${SYSTEM}"

  if [ x"${BD}" = x"yes" ]; then
    mkdir -p "${SYSTEM}/root/yypkg_packages"
    cp "${SOURCE_PATH}"/build_daemon{,_config} "${SYSTEM}/root/yypkg_packages"

    chroot "${SYSTEM}" /bin/bash \
      -c "cd /root/yypkg_packages && ./build_daemon ${BD_CONFIG}"
  else
    (CONFIG=${BD_CONFIG};
     source ${SOURCE_PATH}/build_daemon_config && chroot "${SYSTEM}" /bin/bash)
  fi

  umounts
fi
