#! /bin/bash

# This script does a rough install of VICE 3.6 on the RasPi 4, Bullseye Release
# Last known working on 2022-04-04-raspios-bullseye-armhf-lite.img.xz
# You can download and execute it directly via:
# wget -O - https://raw.githubusercontent.com/erkrystof/vice/master/install-vice-3.6-bullseye-raspi-4.sh | bash
# or download manually:
# wget https://raw.githubusercontent.com/erkrystof/vice/master/install-vice-3.6-bullseye-raspi-4.sh
# chmod +x install-vice-3.6-bullseye-raspi-4.sh
# ./install-vice-3.6-bullseye-raspi-4.sh

set -e

log () {
  echo ""
  echo "****************************************"
  echo "* $1"
  echo "****************************************"
  echo ""
}

log "Installing VICE 3.6 on RasPi 4"

sudo apt update -y
sudo apt full-upgrade -y

sudo apt-get install -y lsb-release git dialog wget gcc g++ build-essential 

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

log "Download VICE 3.6"

wget -O vice-3.6.tar.gz https://sourceforge.net/projects/vice-emu/files/releases/vice-3.6.tar.gz/download
tar xvfz vice-3.6.tar.gz

log "Build VICE 3.6"
cd vice-3.6
./autogen.sh 

 #change --prefix=<dir> if you want the binaries elsewhere
./configure --prefix=/home/pi/vice-3.6 --enable-sdlui2 --without-oss --enable-ethernet \
 --disable-catweasel --without-pulse --enable-x64 --disable-pdf-docs --with-fastsid
make -j $(nproc)
make install
