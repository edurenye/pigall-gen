FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        git vim parted \
        quilt coreutils qemu-user-static debootstrap zerofree zip dosfstools \
        bsdtar libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc\
        binfmt-support ca-certificates \
        pkg-config build-essential cmake \
        libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev \
        python3 python3-distutils \
        libjpeg-dev libtiff5-dev libpng-dev \
        libv4l-dev \
        libxvidcore-dev libx264-dev \
        libatlas-base-dev gfortran \
        libhdf5-dev libhdf5-serial-dev libhdf5-103 \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /pi-gen/

VOLUME [ "/pi-gen/work", "/pi-gen/deploy"]
