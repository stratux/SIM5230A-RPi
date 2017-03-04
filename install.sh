#!/bin/bash


grep -v '^dtoverlay' /boot/config.txt >/tmp/boot_config_tmp
cat /tmp/boot_config_tmp >/boot/config.txt

echo "dtoverlay=pi3-miniuart-bt" >>/boot/config.txt

