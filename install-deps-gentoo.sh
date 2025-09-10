#!/bin/bash
set -e

sudo emerge --ask=n sys-devel/crossdev

sudo crossdev --target arm-none-eabi
sudo crossdev --target arm-linux-gnueabihf

sudo emerge --ask=n --update --newuse \
    app-emulation/qemu \
    sys-devel/gdb
