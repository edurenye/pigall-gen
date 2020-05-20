#!/bin/bash -e

# enable pi camera
cp "${ROOTFS_DIR}/boot/config.txt" "${ROOTFS_DIR}/boot/config_old.txt"
install -m 644 files/config.txt "${ROOTFS_DIR}/boot/"
install -m 644 files/picamera.conf	"${ROOTFS_DIR}/etc/modules-load.d/"
