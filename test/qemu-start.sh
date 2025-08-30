#!/bin/bash

bzImage='./bzImage'
rootfs='./rootfs.img'

qemu-system-x86_64 -nographic \
    -kernel $bzImage \
    -initrd $rootfs \
    -append "root=/dev/ram init=/linuxrc console=ttyS0" # -s -S
