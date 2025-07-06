#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied - Needs arm32 source file and IP of compile server"
fi

if [ ! -d "build" ]
then
	mkdir build
fi

UUID=$(uuidgen)
DIR="arm_build_server/${UUID}/"

# FOLDER STRUCT ON HOST
# == /usr/bin/
# ==== /arm_build_server

# Create folder
sshpass -p 'asm' ssh asm@pet "mkdir -p /usr/bin/${DIR}"

# Move source file to compile server
sshpass -p 'asm' scp $1 asm@pet:/usr/bin/$DIR/

# Assemble and link source file
sshpass -p 'asm' ssh asm@pet "arm-linux-gnueabihf-as -g -o /usr/bin/${DIR}peachykeen32.o /usr/bin/${DIR}m_peachykeen32.s"
sshpass -p 'asm' ssh asm@pet "arm-linux-gnueabihf-ld -o /usr/bin/${DIR}peachykeen32 /usr/bin/${DIR}peachykeen32.o -Ttext=0x10000 --no-dynamic-linker -nostdlib"

# Connect to server and bind stdout and stdin to local streams
sshpass -p 'asm' ssh asm@pet "/usr/bin/${DIR}peachykeen32"

# Clean
sshpass -p 'asm' ssh asm@pet "rm -rf /usr/bin/$DIR" 
