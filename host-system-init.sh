#!/bin/false

# Make sure these variables are defined
echo ${ARCH} ${SYSTEM_COPY} ${SYSTEM} ${LIB} ${CWD} ${YYPKG_SRC} > /dev/null

# When building the cross-compiler host system, the location of the slackware
# binary packages
YYOS_OUTPUT="${CWD}/yy_of_slack/tmp/output-${ARCH}"

# The script mounts several filesystems; these variables keep track of what is
# mounted in order to always umount everything on exit
BIND_MOUNTED_DIRS=""

if [ "${ARCH}" = "i486" ]; then
  YYPKG_TGT_BINARIES="${PWD}/i486"
  SLASH="/home/adrien/t/sbchroot/slackware-current/"
else
  YYPKG_TGT_BINARIES="${YYPKG_SRC}/src"
  SLASH="/"
fi

umounts() {
  if [ -n "${BIND_MOUNTED_DIRS}" ]; then
    umount ${BIND_MOUNTED_DIRS}
    BIND_MOUNTED_DIRS=""
  fi
}

mount_bind() {
  old="$1"
  new="$2"
  mkdir -p "${new}"
  mount --bind "${old}" "${new}"
  BIND_MOUNTED_DIRS="${new} ${BIND_MOUNTED_DIRS}"
}

populate_slash_dev() {
  mkdir ${SYSTEM_COPY}/dev
  mkdir ${SYSTEM_COPY}/dev/pts
  mknod ${SYSTEM_COPY}/dev/console c 5 1
  mknod ${SYSTEM_COPY}/dev/null c 1 3
  mknod ${SYSTEM_COPY}/dev/zero c 1 5
  chmod 666 ${SYSTEM_COPY}/dev/null ${SYSTEM_COPY}/dev/zero
}

# copy_ld_so: install the base libc files inside the chroot
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

chroot_run() {
  DIR="${1}"
  shift
  YYPREFIX="/" \
    LANG="en_US.UTF-8" \
    PATH="${INITDIR}/host/bin:${PATH}" \
    LD_LIBRARY_PATH="${INITDIR}/host/${LIB}:${INITDIR}/host/usr/${LIB}" \
  chroot "${DIR}" $*
}

INITDIR="/tmp/yypkg_init" # temp directory
INITDIR_FULL="${SYSTEM_COPY}/${INITDIR}" # absolute path; outside the chroot

mkdir -p ${INITDIR_FULL}/pkgs

rsync --archive "${YYOS_OUTPUT}/" "${INITDIR_FULL}/pkgs/"

copy_ld_so

mkdir -p "${SYSTEM_COPY}/sbin"
for bin in "yypkg" "makeypkg" "sherpa" "sherpa_gen"; do
  cp "${YYPKG_TGT_BINARIES}/${bin}.native" "${SYSTEM_COPY}/sbin/${bin}"
done

trap umounts EXIT SIGINT ERR

for dir in bin ${LIB} usr/${LIB}; do
  mount_bind "${SLASH}${dir}" "${INITDIR_FULL}/host/${dir}"
done

populate_slash_dev

chroot_run "${SYSTEM_COPY}" "/sbin/yypkg" "-init"

# Install all packages
find "${INITDIR_FULL}/pkgs" -maxdepth 1 -name '*.txz' -printf '%f\n' \
  | while read PKG; do
    chroot_run "${SYSTEM_COPY}" "/sbin/yypkg" "-install" "${INITDIR}/pkgs/${PKG}" || true
done

if [ -e "${SYSTEM_COPY}/usr/bin/ccache" ]; then
  chroot "${SYSTEM_COPY}" "/usr/bin/ccache" "--max-size=2G"
fi

umounts

(cd ${SYSTEM_COPY}/tmp/
rm -r yypkg_init/pkgs
rmdir yypkg_init/host/{bin,lib64,usr/lib64,usr} .{ICE,X11}-unix)

for bin in cc c++ {${ARCH}-slackware-linux-,}{gcc,g++}; do
  ln -s "/usr/bin/ccache" "${SYSTEM_COPY}/usr/local/bin/${bin}"
done

cp "${CWD}/get-all-prebuilt-binaries-i686.sh" "${SYSTEM_COPY}/root"

echo 'nameserver 208.67.222.222' > /etc/resolv.conf

cp -r --preserve="mode,timestamps" "${SYSTEM_COPY}" "${SYSTEM}"
