#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied - Needs arm32 source file and IP of compile server"
    exit 1
fi

if [ ! -d "build" ]
then
	mkdir build
fi

UUID=$(uuidgen)
DIR="arm_build_server/${UUID}/"

FILENAME=$(basename "$1")
BASENAME="${FILENAME%.*}"

sshpass -p 'asm' ssh asm@pet "mkdir -p /usr/bin/${DIR}"

sshpass -p 'asm' scp "$1" asm@pet:/usr/bin/$DIR/

sshpass -p 'asm' ssh asm@pet "arm-linux-gnueabihf-as -g -o /usr/bin/${DIR}${BASENAME}.o /usr/bin/${DIR}${FILENAME}"
sshpass -p 'asm' ssh asm@pet "arm-linux-gnueabihf-ld -o /usr/bin/${DIR}${BASENAME} /usr/bin/${DIR}${BASENAME}.o -Ttext=0x10000 --no-dynamic-linker -nostdlib"

sshpass -p 'asm' ssh asm@pet "/usr/bin/${DIR}${BASENAME}"

sshpass -p 'asm' ssh asm@pet "rm -rf /usr/bin/$DIR"

