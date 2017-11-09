#!/bin/bash
#
# build static find because we need exercises in minimalism
# MIT licensed: google it or see robxu9.mit-license.org.
#
# For Linux, also builds musl for truly static linking.

find_version="4.6.0"
musl_version="1.1.15"

platform=$(uname -s)

if [ -d build ]; then
  echo "= removing previous build directory"
  rm -rf build
fi

mkdir build # make build directory
pushd build

# download tarballs
echo "= downloading find"
curl -LO http://ftp.gnu.org/gnu/findutils/findutils-${find_version}.tar.gz

echo "= extracting find"
tar -xf findutils-${find_version}.tar.gz

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

echo "= building find"

pushd findutils-${find_version}
CFLAGS="$CFLAGS -Os -ffunction-sections -fdata-sections" LDFLAGS='-Wl,--gc-sections' ./configure --without-bash-malloc
make
popd # find-${find_version}

popd # build

if [ ! -d releases ]; then
  mkdir releases
fi

echo "= striptease"
strip -s -R .comment -R .gnu.version --strip-unneeded build/findutils-${find_version}/find
echo "= compressing"
upx --ultra-brute build/findutils-${find_version}/find/find
echo "= extracting find binary"
cp build/findutils-${find_version}/find/find releases
echo "= done"
