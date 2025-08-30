#!/bin/bash

bzImage='./bzImage'
rootfs='./rootfs.img'
debug_arg=""
share_arg=""

if [ ! -f $bzImage ]; then
    echo "Error: $bzImage not exist"
    exit 1
fi

if [ ! -f $rootfs ]; then
    echo "Error: $rootfs not exist"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        -d)
            echo "The system is running in debug mode, use the following method to connect:"
            echo "> gdb ./vmlinux"
            echo "(gdb) target remote 127.0.0.1:1234"
            debug_arg="-s -S"
            ;;
        -s)
            echo "Shared folder: /mnt/shared"
            share_arg="-virtfs local,path=/mnt/shared,mount_tag=host0,security_model=none,id=host0"
            ;;
    esac
    shift
done

qemu-system-x86_64 -nographic \
    -kernel $bzImage \
    -initrd $rootfs \
    $debug_arg $share_arg \
    -append "root=/dev/ram init=/linuxrc console=ttyS0"
