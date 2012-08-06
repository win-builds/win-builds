#!/bin/bash -eux

LOCATION="${1}" # Work directory
BD_CONFIG="${2:-"windows_32"}" # What to build?
BD="${3:-"no"}" # If "no", start a shell instead of build-daemon

CWD="$(pwd)"

SOURCE_PATH="$(cd "$(dirname "${0}")" && pwd)"

mkdir -p "${LOCATION}/packages" "${LOCATION}/logs"
LOCATION="$(cd "${LOCATION}" && pwd)"

# The script mounts several filesystems; these variables keep track of what is
# mounted in order to always umount everything on exit
BIND_MOUNTED_DIRS=""
SPECIAL_FILESYSTEMS=""

# The architecture of the system inside the chroot
ARCH="x86_64"

SYSTEM_COPY="${LOCATION}/system_copy"
SYSTEM="${LOCATION}/system"

if [ "${ARCH}" = "i486" ]; then
  LIB="lib"
else
  LIB="lib64"
fi

umounts() {
  if [ -n "${BIND_MOUNTED_DIRS}" -o -n "${SPECIAL_FILESYSTEMS}" ]; then
    umount ${BIND_MOUNTED_DIRS} ${SPECIAL_FILESYSTEMS}
    BIND_MOUNTED_DIRS=""
    SPECIAL_FILESYSTEMS=""
  fi
}

# Build the cross-compiler host system if ${SYSTEM} doesn't exist
if [ ! -e "${SYSTEM}" ]; then
  ARCH="${ARCH}" LIB="${LIB}" SYSTEM="${SYSTEM}" SYSTEM_COPY="${SYSTEM_COPY}" \
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
