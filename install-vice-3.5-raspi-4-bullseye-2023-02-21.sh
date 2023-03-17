#! /bin/bash

# This script does a rough install of VICE on the Raspberry Pi
# VICE Version: 3.5
# Raspberry Pi OS: 2023-02-21-raspios-bullseye-armhf-lite.img.xz
# You can download and execute it directly via:
# wget -O - https://raw.githubusercontent.com/erkrystof/vice/master/install-vice-3.5-raspi-4-bullseye-2023-02-21.sh | bash
# or download manually and execute:
# wget https://raw.githubusercontent.com/erkrystof/vice/master/install-vice-3.5-raspi-4-bullseye-2023-02-21.sh
# chmod +x install-vice-3.5-raspi-4-bullseye-2023-02-21.sh
# ./install-vice-3.5-raspi-4-bullseye-2023-02-21.sh

set -e

KIO_VICE_VERSION=3.5
KIO_RASPI_OS_NAME=Bullseye

trap 'catch $? $LINENO' EXIT

catch() {
  echo "Exiting!"
  if [ "$1" != "0" ]; then
    # error handling goes here
    echo "Error $1 occurred on $2"
  fi
}

log () {
  echo ""
  echo "****************************************"
  echo "* $1"
  echo "****************************************"
  echo ""
}

log "Installing VICE ${KIO_VICE_VERSION} on RasPi 4"

sudo apt update -y
sudo apt upgrade -y

log "Install previous SDL local build dependencies - but may be needed for VICE compile"

sudo apt-get install -y lsb-release git dialog wget gcc g++ build-essential unzip xmlstarlet \
  python3-pyudev ca-certificates libasound2-dev libudev-dev libibus-1.0-dev libdbus-1-dev \
  fcitx-libs-dev libsndio-dev libx11-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev \
  libxkbcommon-dev libxrandr-dev libxss-dev libxt-dev libxv-dev libxxf86vm-dev libgl1-mesa-dev \
  libegl1-mesa-dev libgles2-mesa-dev libgl1-mesa-dev libglu1-mesa-dev libdrm-dev libgbm-dev \
  devscripts debhelper dh-autoreconf libraspberrypi-dev libpulse-dev

log "Download VICE dependencies"

#vice dependencies
sudo apt install libmpg123-dev libpng-dev zlib1g-dev libasound2-dev libvorbis-dev libflac-dev \
 libpcap-dev automake bison flex subversion libjpeg-dev portaudio19-dev texinfo xa65 dos2unix \
 libsdl2-image-dev libsdl2-dev libsdl2-2.0-0 -y

if [ -d ~/vice-src ]
then
    echo "Directory vice-src exists already.  Heading on in."
else
    mkdir ~/vice-src
fi
cd ~/vice-src

log "Download VICE ${KIO_VICE_VERSION}"

wget -O vice-${KIO_VICE_VERSION}.tar.gz https://sourceforge.net/projects/vice-emu/files/releases/vice-${KIO_VICE_VERSION}.tar.gz/download
tar xvfz vice-${KIO_VICE_VERSION}.tar.gz

log "Autogen VICE"
cd vice-${KIO_VICE_VERSION}
./autogen.sh 

log "Configure VICE"
 
#change --prefix=<dir> if you want the binaries elsewhere
./configure --prefix=${HOME}/vice-${KIO_VICE_VERSION} --enable-sdl2ui --without-oss --enable-ethernet \
 --disable-catweasel --without-pulse --enable-x64 --disable-pdf-docs --with-fastsid
 
log "Make VICE"
 
make -j $(nproc)

log "Install VICE"

make install

log "Done!  You can delete vice-src and sdl-work at your leisure.  Vice is installed at ${HOME}/vice-${KIO_VICE_VERSION}"

cd ${HOME}/vice-${KIO_VICE_VERSION}/bin

ls