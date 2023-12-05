FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison -y

RUN apt-get install vim-tiny -y
