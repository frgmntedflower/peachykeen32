#!/bin/bash
set -e
sudo apt update
sudo apt install -y \
    gcc-arm-linux-gnueabihf \
    binutils-arm-linux-gnueabihf \
    qemu-user \
    gdb-multiarch \
    make \
    build-essential
