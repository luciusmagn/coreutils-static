#!/bin/bash
#
# build static coreutils because we need exercises in minimalism
# MIT licensed: google it or see robxu9.mit-license.org.
#
# For Linux, also builds musl for truly static linking.

coreutils_version="8.28"
musl_version="1.1.15"

platform=$(uname -s)

if [ -d build ]; then
  echo "= removing previous build directory"
  rm -rf build
fi

mkdir build # make build directory
pushd build

# download tarballs
echo "= downloading coreutils"
curl -LO http://ftp.gnu.org/gnu/coreutils/coreutils-${coreutils_version}.tar.xz

echo "= extracting coreutils"
tar xJf coreutils-${coreutils_version}.tar.xz

if [ "$platform" = "Linux" ]; then
  echo "= downloading musl"
  curl -LO http://www.musl-libc.org/releases/musl-${musl_version}.tar.gz

  echo "= extracting musl"
  tar -xf musl-${musl_version}.tar.gz

  echo "= building musl"
  working_dir=$(pwd)

  install_dir=${working_dir}/musl-install

  pushd musl-${musl_version}
  env CFLAGS="$CFLAGS -Os -ffunction-sections -fdata-sections" LDFLAGS='-Wl,--gc-sections' ./configure --prefix=${install_dir}
  make install
  popd # musl-${musl-version}

  echo "= setting CC to musl-gcc"
  export CC=${working_dir}/musl-install/bin/musl-gcc
  export CFLAGS="-static"
else
  echo "= WARNING: your platform does not support static binaries."
  echo "= (This is mainly due to non-static libc availability.)"
fi

echo "= building coreutils"

pushd coreutils-${coreutils_version}
env FORCE_UNSAFE_CONFIGURE=1 CFLAGS="$CFLAGS -Os -ffunction-sections -fdata-sections" LDFLAGS='-Wl,--gc-sections' ./configure
make
popd # coreutils-${coreutils_version}

popd # build

if [ ! -d releases ]; then
  mkdir releases
fi

echo "= striptease"
strip -s -R .comment -R .gnu.version --strip-unneeded build/coreutils-${coreutils_version}/coreutils
echo "= compressing"

shopt -s extglob
for file in build/coreutils-${coreutils_version}/src/!(*.*)
do
	upx --ultra-brute $file
done
echo "= extracting coreutils binary"
cp build/coreutils-${coreutils_version}/src/!(*.*) releases
echo "= done"
