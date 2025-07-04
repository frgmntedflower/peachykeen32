#!/bin/bash

if [ ! -d "build" ]
then
	mkdir build
fi

arm-linux-gnueabihf-as -g -o build/peachykeen32.o src/m_peachykeen32.s
arm-linux-gnueabihf-ld -o build/peachykeen32 build/peachykeen32.o -Ttext=0x10000 --no-dynamic-linker -nostdlib

