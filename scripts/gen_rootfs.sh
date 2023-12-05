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
    echo "proc        /proc   proc    defaults    0   0" >> etc/fstab
    echo "tmpfs       /tmp    tmpfs   defaults    0   0" >> etc/fstab
    echo "sysfs       /sys    sysfs   defaults    0   0" >> etc/fstab
}

init_file_inittab() {
    echo "::sysinit:/etc/init.d/rcS"        >> etc/inittab
    echo "::respawn:-/bin/sh"               >> etc/inittab
    echo "tty2::askfirst:-/bin/sh"          >> etc/inittab
    echo "::ctrlaltdel:/bin/umount -a -r"   >> etc/inittab
}

init_file_profile() {
    echo '# /etc/profile: system-wide .profile file for the Bourne shells' >> etc/profile
    echo ''                                         >> etc/profile
    echo 'echo'                                     >> etc/profile
    echo 'echo -n "Processing /etc/profile... "'    >> etc/profile
    echo '# no-op'                                  >> etc/profile
    echo 'echo "Done"'                              >> etc/profile
    echo 'echo'                                     >> etc/profile
}

init_file_rcS() {
    echo '#! /bin/sh'           >> etc/init.d/rcS
    echo ''                     >> etc/init.d/rcS
    echo '/bin/mount -a'        >> etc/init.d/rcS
    echo ''                     >> etc/init.d/rcS
    echo 'echo "rcS done here"' >> etc/init.d/rcS
}

init_etc() {
    touch etc/fstab && init_file_fstab && echo "create etc/fstab file done"
    touch etc/inittab && init_file_inittab && echo "create etc/inittab file done"
    touch etc/profile && init_file_profile && echo "create etc/profile file done"
    mkdir -p etc/init.d/ && touch etc/init.d/rcS && init_file_rcS && echo  "create etc/init.d/rcS done"

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
        sudo umount $1 && echo "umount $1 done here"
    else
        echo "not include busybox file!!!"
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
    mkdir {dev/,etc/,lib/,proc/,sys/,tmp/}

    init_dev
    init_etc

    cd .. && sudo cp -rf $DirNameTmp/* $DirName && echo "copy file done here"
    rm -rf $DirNameTmp

    init_busybox $DirName

    echo "init done here"
}

main
