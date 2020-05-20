#!/bin/bash -e

# Remove rfkill and raspberrypi-sys-mods
#on_chroot << EOF
#rfkill unblock wifi
#apt purge -y rfkill raspberrypi-sys-mods
#EOF

# Networks
echo "Setting up wifi..."
cp "${ROOTFS_DIR}/etc/network/interfaces" "${ROOTFS_DIR}/etc/network/interfaces_old"
install -m 644 files/interfaces "${ROOTFS_DIR}/etc/network/"
cp files/wlan-up.sh "${ROOTFS_DIR}/etc/init.d/"
cp "${ROOTFS_DIR}/etc/rc.local" "${ROOTFS_DIR}/etc/rc.local_old"
install -m 755 files/rc.local	"${ROOTFS_DIR}/etc/"

# DHCP
echo "Setting up dhcp..."
cp "${ROOTFS_DIR}/etc/dhcp/dhcpd.conf" "${ROOTFS_DIR}/etc/dhcp/dhcpd_old.conf"
install -m 644 files/dhcpd.conf "${ROOTFS_DIR}/etc/dhcp/"
install -m 644 files/isc-dhcp-server "${ROOTFS_DIR}/etc/default/"

# AP
echo "Setting up AP..."
install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/"
cp "${ROOTFS_DIR}/etc/default/hostapd" "${ROOTFS_DIR}/etc/default/hostapd_old"
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> "${ROOTFS_DIR}/etc/default/hostapd"

# Enable SSH
touch "${ROOTFS_DIR}/boot/ssh"
