#!/usr/bin/env bash

VERSION="5.15.102"

# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
apt update
apt install -y wget git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison
apt build-dep -y linux

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source
wget http://www.kernel.org/pub/linux/kernel/v5.x/linux-"$VERSION".tar.xz
tar -xf linux-"$VERSION".tar.xz
cd linux-"$VERSION" || exit

# copy config file
cp ../config .config

# disable DEBUG_INFO to speedup build
scripts/config --disable DEBUG_INFO

# apply patches
# shellcheck source=src/util.sh
patch -p1 < ../patch.d/gpl.patch

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
make deb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
cd ..
rm -rfv *dbg*.deb
mkdir "artifact"
mv ./*.deb artifact/
