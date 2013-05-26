#!/bin/bash

# STATIC :
#   ./compile.sh 8 fips static
#   make install
#
# NOTE : make sure you own /usr/local/ssl, the cross compiled fips will land there.
#
# SHARED :
#   ./compile.sh 8 ssl static
#
# NOTE : fipsld calls the host's 'ar' and 'ranlib' binaries, so make sure that you have the NDK versions of 'ar' and 'ranlib' symlinked as 'ar' and 'ranlib' in your ndk bin dir and set your path so both ar and ranlib is run from your NDK dir
# NOTE : the script users NDK versions 5b and 8, change it to your installation
# NOTE : FIPS_SIG must point to the 'incore' script that came with your openssl*fips*tgz

NDKV=$1
STAGE=$2
TYPE=$3

if [ -z $NDKV ]; then
  echo "$(basename $0) 5b|8 <fips|ssl> <shared|static>"
  exit 1
fi

NDKP="$HOME/wrk/devel/android-ndk-r"

export HOSTCC="/usr/bin/gcc"
export FIPS_SIG="/tmp/openssl-fips-2.0.2/util/incore"

if [ $NDKV == "5b" ]; then
  export CROSS_COMPILE="${NDKP}5b/toolchains/arm-eabi-4.4.0/prebuilt/darwin-x86/bin/arm-eabi-"
  export ANDROID_DEV="${NDKP}5b/platforms/android-8/arch-arm/usr/"
elif [ $NDKV == "8" ]; then
  export CROSS_COMPILE="${NDKP}8/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-"
  export ANDROID_DEV="${NDKP}8/platforms/android-8/arch-arm/usr/"
else
  echo "wrong"
  exit 1
fi

if [ $STAGE == "fips" ]; then
  ./Configure android fipscanisterbuild
  make
else
  if [ $TYPE == "static" ]; then
    ./Configure android fips
    make depend
    make
  else
    ./Configure android shared fips
    make depend
    make
  fi
fi
