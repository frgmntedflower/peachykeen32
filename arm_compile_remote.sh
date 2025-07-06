#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments supplied - Needs arm32 source"
    exit 1
fi

UUID=$(uuidgen)
DIR="arm_build_server/${UUID}/"

FILEPATH="$1"
FILENAME=$(basename "$FILEPATH")
BASENAME="${FILENAME%.*}"
SRC_DIR=$(dirname "$FILEPATH")

REMOTE_DIR="/usr/bin/${DIR}"

# Create remote directory
sshpass -p 'asm' ssh asm@pet "mkdir -p ${REMOTE_DIR}"

# Copy only contents of the source folder (not the folder itself)
sshpass -p 'asm' scp -r "${SRC_DIR}/"* asm@pet:"${REMOTE_DIR}"

# Compile and link
sshpass -p 'asm' ssh asm@pet "arm-linux-gnueabihf-as -g -o ${REMOTE_DIR}${BASENAME}.o ${REMOTE_DIR}${FILENAME}"
sshpass -p 'asm' ssh asm@pet "arm-linux-gnueabihf-ld -o ${REMOTE_DIR}${BASENAME} ${REMOTE_DIR}${BASENAME}.o -Ttext=0x10000 --no-dynamic-linker -nostdlib"

# Execute the binary
sshpass -p 'asm' ssh asm@pet "${REMOTE_DIR}${BASENAME}"

# Clean up
sshpass -p 'asm' ssh asm@pet "rm -rf ${REMOTE_DIR}"

