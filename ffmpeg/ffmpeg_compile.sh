#!/bin/bash

# This script compiles and creates a package for the FFmpeg version specified in VERSION.
# Compilation target is x86_64 mingw32

set -e

THIS=$(readlink -e $0)
VERSION=6.0
INSTALL_DIR=ffmpeg-${VERSION}

REQUIRED_DLLS_NAME=requirements.txt

if [ ! -d "FFmpeg" ]; then
    git clone --branch "n${VERSION}" --depth 1 https://github.com/FFmpeg/FFmpeg.git
fi

cd FFmpeg

AVCODEC_VER=$(grep '#define LIBAVCODEC_VERSION_MAJOR' libavcodec/version_major.h | sed 's/.* //g')
AVUTIL_VER=$(grep '#define LIBAVUTIL_VERSION_MAJOR' libavutil/version.h | sed 's/.* //g')
SWSCALE_VER=$(grep '#define LIBSWSCALE_VERSION_MAJOR' libswscale/version_major.h | sed 's/.* //g')
AVFILTER_VER=$(grep '#define LIBAVFILTER_VERSION_MAJOR' libavfilter/version_major.h | sed 's/.* //g')

REQUIRED_DLLS="avcodec-${AVCODEC_VER}.dll;avutil-${AVUTIL_VER}.dll;libwinpthread-1.dll;swscale-${SWSCALE_VER}.dll;avfilter-${AVFILTER_VER}.dll"

if [ -d "build" ]; then
    rm -rf build
    mkdir build
else
    mkdir build
fi

cd build
../configure \
    --enable-cross-compile \
    --arch=x86_64 \
    --target-os=mingw32 \
    --cross-prefix=x86_64-w64-mingw32- \
    --disable-avdevice \
    --disable-avformat \
    --disable-doc \
    --disable-everything \
    --disable-ffmpeg \
    --disable-ffprobe \
    --disable-network \
    --disable-postproc \
    --disable-swresample \
    --disable-vaapi \
    --disable-vdpau \
    --enable-decoder={h264,vp8,vp9} \
    --enable-avfilter \
    --enable-shared \
    --disable-iconv \
    --enable-filter=yadif,scale \
    --enable-d3d11va \
    --enable-hwaccel={h264_nvdec,vp9_nvdec} \
    --enable-nvdec \
    --enable-ffnvcodec \
    --enable-cuvid \
    --prefix=/
make -j$(nproc)

mkdir ${INSTALL_DIR}
make install DESTDIR=${INSTALL_DIR}
cp ${THIS} ${INSTALL_DIR}
echo -n ${REQUIRED_DLLS} > ${INSTALL_DIR}/${REQUIRED_DLLS_NAME}
cp $(find /usr/x86_64-w64-mingw32/ | grep libwinpthread-1.dll | head -n 1) ${INSTALL_DIR}/bin
7z a ${INSTALL_DIR}.7z ${INSTALL_DIR}
