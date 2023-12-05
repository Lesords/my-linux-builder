# my-linux-builder

## Introduction

This repository is to make compiling the kernel easier

## Build and run docker container

```bash
git clone git@github.com:Lesords/my-linux-builder.git --depth 1
cd my-linux-builder
```

```bash
docker build . -t teeny-linux-builder
docker container run -it teeny-linux-builder
```

Ps: Currently, you can only generate images that satisfy the kernel compilation environment

## Generate root filesystem image

```bash
cd test
../scripts/gen_rootfs.sh
```

This script will generate a root filesystem image in the current directory.

Note that, the root filesystem generated by default is incomplete and no umount operation is performed.
If you have already compiled busybox, you can put the compilation results in the test folder, and then execute the script.

The file structure is as follows:

```bash
test
├── busybox
│   └── _install
└── init.sh
```

## Test

Put the image and root file system in the test folder

Then, run

```bash
./init.sh
```
