#!/bin/bash
set -e
sudo pacman -Sy --needed --noconfirm \
    arm-none-eabi-binutils \
    arm-linux-gnueabihf-gcc \
    qemu-user \
    gdb-multiarch \
    base-devel
