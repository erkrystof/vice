#! /bin/bash

# This script does a rough install of VICE 3.5 on the RasPi 4.
# You can download and execute it directly via:
# wget -O - https://raw.githubusercontent.com/erkrystof/vice/master/install-vice-3.5-raspi-4.sh | bash
# or download manually:
# wget https://raw.githubusercontent.com/erkrystof/vice/master/install-vice-3.5-raspi-4.sh
# chmod +x install-vice-3.5-raspi-4.sh
# ./install-vice-3.5-raspi-4.sh

set -e

log () {
  echo ""
  echo "****************************************"
  echo "* $1"
  echo "****************************************"
  echo ""
}

log "Installing VICE 3.5 on RasPi 4"
#log "Normal Raspi update/upgrade path"

#sudo apt update
#sudo apt full-upgrade

log "SDL2 Dependencies (for kmsdrm)"

#install dependencies for how we'll compile SDL2 and install the output package
sudo apt update -y
sudo apt upgrade -y


sudo apt-get install -y lsb-release git dialog wget gcc g++ build-essential unzip xmlstarlet \
  python3-pyudev ca-certificates libasound2-dev libudev-dev libibus-1.0-dev libdbus-1-dev \
  fcitx-libs-dev libsndio-dev libx11-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev \
  libxkbcommon-dev libxrandr-dev libxss-dev libxt-dev libxv-dev libxxf86vm-dev libgl1-mesa-dev \
  libegl1-mesa-dev libgles2-mesa-dev libgl1-mesa-dev libglu1-mesa-dev libdrm-dev libgbm-dev \
  devscripts debhelper dh-autoreconf libraspberrypi-dev libpulse-dev 
 
if [ -d ~/sdl-work ] 
then
    echo "Directory sdl-work exists already.  Heading on in." 
else
    mkdir ~/sdl-work
fi
cd ~/sdl-work

log "Download SDL 2.0.14"

rm -rf ./SDL-mirror
git clone --single-branch --branch retropie-2.0.14 https://github.com/erkrystof/SDL-mirror
cd SDL-mirror

log "Config and Compile SDL 2.0.14"

#update debian package rules and control files, which update dependencies specific
#to the raspberry pi and enables kmsdrm
 
conf_depends="libasound2-dev, libudev-dev, libibus-1.0-dev, libdbus-1-dev, fcitx-libs-dev, libsndio-dev, libx11-dev, libxcursor-dev, libxext-dev, libxi-dev, libxinerama-dev, libxkbcommon-dev, libxrandr-dev, libxss-dev, libxt-dev, libxv-dev, libxxf86vm-dev, libgl1-mesa-dev, libegl1-mesa-dev, libgles2-mesa-dev, libgl1-mesa-dev, libglu1-mesa-dev, libdrm-dev, libgbm-dev,"
 
sed -i 's/libgl1-mesa-dev,/libgl1-mesa-dev, '"${conf_depends[*]}"'/' ./debian/control
 
conf_flags="--disable-video-vulkan --enable-video-rpi --enable-video-kmsdrm"
 
sed -i 's/confflags =/confflags = '"${conf_flags[*]}"' \\\n/' ./debian/rules
 
# move proprietary videocore headers
sed -i -e 's/\"EGL/\"brcmEGL/g' -e 's/\"GLES/\"brcmGLES/g' ./src/video/raspberry/SDL_rpivideo.h
sudo mv /opt/vc/include/EGL /opt/vc/include/brcmEGL
sudo mv /opt/vc/include/GLES /opt/vc/include/brcmGLES
sudo mv /opt/vc/include/GLES2 /opt/vc/include/brcmGLES2
 
#perform the build via dpkg-buildpackage
PKG_CONFIG_PATH= dpkg-buildpackage -b

# restore proprietary headers
sudo mv /opt/vc/include/brcmEGL /opt/vc/include/EGL
sudo mv /opt/vc/include/brcmGLES /opt/vc/include/GLES
sudo mv /opt/vc/include/brcmGLES2 /opt/vc/include/GLES2
 
#remove any old installed library
sudo dpkg --remove libsdl2 libsdl2-dev
 
#move to where those .deb packages are (right above us)
cd ~/sdl-work
 
log "Install our custom SDL 2.0.14"

if ! sudo dpkg -i libsdl2-2.0-0_2.0.14_armhf.deb libsdl2-dev_2.0.14_armhf.deb ; then
    sudo apt-get -y -f --no-install-recommends install
fi
echo "libsdl2-dev hold" | sudo dpkg --set-selections

log "Download VICE dependencies"

#vice dependencies
sudo apt install libmpg123-dev libpng-dev zlib1g-dev libasound2-dev libvorbis-dev libflac-dev \
 libpcap-dev automake bison flex subversion libjpeg-dev portaudio19-dev texinfo xa65 dos2unix \
 libsdl2-image-dev -y

if [ -d ~/vice-src ]
then
    echo "Directory vice-src exists already.  Heading on in."
else
    mkdir ~/vice-src
fi
cd ~/vice-src

log "Download VICE 3.5"

wget -O vice-3.5.tar.gz https://sourceforge.net/projects/vice-emu/files/releases/vice-3.5.tar.gz/download
tar xvfz vice-3.5.tar.gz

log "Build VICE 3.5"
cd vice-3.5
./autogen.sh 

 #change --prefix=<dir> if you want the binaries elsewhere
./configure --prefix=/home/pi/vice-3.5 --enable-sdlui2 --without-oss --enable-ethernet \
 --disable-catweasel --without-pulse --enable-x64 --disable-pdf-docs --with-fastsid
make -j $(nproc)
make install

