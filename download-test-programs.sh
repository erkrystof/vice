#! /bin/bash

# Downloads test D64 files
# wget -O - https://raw.githubusercontent.com/erkrystof/vice/master/download-test-programs.sh | bash
# 
set -e

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


log "Downloading some test programs for VICE"

if [ -d ~/testprograms ] 
then
    echo "Directory testprograms exists already. Doing nothing."
else
    mkdir ~/testprograms
    wget -P testprograms/ https://raw.githubusercontent.com/erkrystof/vice/master/testprograms/delaytest.d64
    wget -P testprograms/ https://raw.githubusercontent.com/erkrystof/vice/master/testprograms/Disco_Apocalypso_by_SHAPE.d64
    wget -P testprograms/ https://raw.githubusercontent.com/erkrystof/vice/master/testprograms/Remains BD.d64
fi


log "Done!"
