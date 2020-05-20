#!/bin/bash

echo "Wlan0 up on first-boot."
rfkill unblock wifi
ifconfig wlan0 up

echo "Removing script."
rm $0
