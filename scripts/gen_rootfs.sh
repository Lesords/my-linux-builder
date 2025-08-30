#!/bin/bash

init_ext3() {
    Ext3File=$1
    ImageFile=rootfs.img

    if [ -e $ImageFile ]; then
        if [ "`mount | grep $Ext3File | wc -l`" -ne "0" ]; then
            sudo umount $Ext3File && echo "sudo umount $Ext3File done here"
        fi
        rm -rf $ImageFile
    fi
    dd if=/dev/zero of=$ImageFile bs=1M count=10
    mkfs.ext3 $ImageFile && echo "[$ImageFile] init done here"

   if [ -d $Ext3File ]; then
        rm -rf $Ext3File
    fi
    mkdir $Ext3File && echo "create [$Ext3File] done here"

    sudo mount -t ext3 -o loop $ImageFile $Ext3File && \
        echo "[$ImageFile] mount on [$Ext3File]" && echo
}

init_file_fstab() {
    cat << EOF >> etc/fstab
proc        /proc   proc    defaults    0   0
tmpfs       /tmp    tmpfs   defaults    0   0
sysfs       /sys    sysfs   defaults    0   0
EOF
}

init_file_inittab() {
    cat << EOF >> etc/inittab
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
tty2::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF
}

init_file_profile() {
    cat << EOF >> etc/profile
# /etc/profile: system-wide .profile file for the Bourne shells

echo
echo -n "Processing /etc/profile... "
# no-op
echo "Done"
echo
EOF
}

init_file_rcS() {
    cat << EOF >> etc/init.d/rcS
#!/bin/sh

/bin/mount -a

mount -o remount, rw /

mkdir -p /mnt/shared && \
mount -t 9p -o trans=virtio,version=9p2000.L host0 /mnt/shared

echo "rcS done here"
EOF
}

init_file_passwd() {
    cat << EOF >> etc/passwd
root:x:0:0:root:/root:/bin/sh
EOF
}

init_etc() {
    touch etc/fstab && init_file_fstab && echo "create etc/fstab file done"
    touch etc/inittab && init_file_inittab && echo "create etc/inittab file done"
    touch etc/profile && init_file_profile && echo "create etc/profile file done"
    mkdir -p etc/init.d/ && touch etc/init.d/rcS && init_file_rcS && echo  "create etc/init.d/rcS done"

    touch etc/passwd && init_file_passwd && echo "create etc/passwd file done"

    chmod 755 etc/init.d/rcS
}

init_dev() {
    sudo mknod dev/console c 5 1
    sudo mknod dev/ram b 1 0
}

init_busybox() {
    busyboxPath=`ls | grep busybox | head -1`
    busyboxFile='_install'

    if [ "$busyboxPath" -a -d $busyboxPath/$busyboxFile ]; then
        sudo cp -rf $busyboxPath/$busyboxFile/* $1 && \
            echo "$busyboxPath/$busyboxFile copy done here!!!"
        sudo chmod 4755 $1/bin/busybox
        sudo umount $1 && echo "umount $1 done here"
    else
        sudo umount $1
        echo "Error: not include busybox file!!!"
        exit 1
    fi
}

main() {
    DirName=rootfs
    DirNameTmp=rootfs_tmp

    init_ext3 $DirName
    
    if [ -e $DirNameTmp ]; then
        rm -rf $DirNameTmp
    fi

    mkdir $DirNameTmp && cd $DirNameTmp && echo "entering $DirNameTmp..."
    mkdir {dev/,etc/,lib/,proc/,sys/,tmp/,root/}

    init_dev
    init_etc

    cd .. && sudo cp -rf $DirNameTmp/* $DirName && echo "copy file done here" && echo
    rm -rf $DirNameTmp

    init_busybox $DirName

    echo "init done here"
}

main
