#! /bin/bash
set -e

log () {
  echo ""
  echo "****************************************"
  echo "* $1"
  echo "****************************************"
  echo ""
}

log "Normal Raspi update/upgrade path"

sudo apt update
sudo apt full-upgrade

log "SDL2 Dependencies (for kmsdrm)"

#install dependencies for how we'll compile SDL2 and install the output package
sudo apt install lsb-release git dialog wget gcc g++ build-essential unzip xmlstarlet \
  python3-pyudev ca-certificates libasound2-dev libudev-dev libibus-1.0-dev libdbus-1-dev \
  fcitx-libs-dev libsndio-dev libx11-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev \
  libxkbcommon-dev libxrandr-dev libxss-dev libxt-dev libxv-dev libxxf86vm-dev libgl1-mesa-dev \
  libegl1-mesa-dev libgles2-mesa-dev libgl1-mesa-dev libglu1-mesa-dev libdrm-dev libgbm-dev \
  devscripts debhelper dh-autoreconf libraspberrypi-dev libpulse-dev 
  

mkdir ~/sdl-work
cd ~/sdl-work

log "Download SDL 2.0.14"

wget https://libsdl.org/release/SDL2-2.0.14.tar.gz
tar xvfz SDL2-2.0.14.tar.gz
cd SDL2-2.0.14
#git clone --single-branch --branch retropie-2.0.14 https://github.com/erkrystof/SDL-mirror
#cd SDL-mirror

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
 
if ! sudo dpkg -i libsdl2-2.0-0_2.0.10_armhf.deb libsdl2-dev_2.0.10_armhf.deb ; then
    sudo apt-get -y -f --no-install-recommends install
fi
echo "libsdl2-dev hold" | sudo dpkg --set-selections

#vice dependencies
sudo apt install libmpg123-dev libpng-dev zlib1g-dev libasound2-dev libvorbis-dev libflac-dev \
 libpcap-dev automake bison flex subversion libjpeg-dev portaudio19-dev texinfo xa65 dos2unix \
 libsdl2-image-dev


mkdir ~/vice-src
cd ~/vice-src

wget -O vice-3.5.tar.gz https://sourceforge.net/projects/vice-emu/files/releases/vice-3.5.tar.gz/download

tar xvfz vice-3.5.tar.gz

cd vice-3.5

./autogen.sh 

 #pass --prefix=<dir> if you want the binaries elsewhere
./configure --enable-sdlui2 --without-oss --enable-ethernet \
 --disable-catweasel --without-pulse --enable-x64 --disable-pdf-docs --with-fastsid
make -j $(nproc)
make install

 
