#!/bin/bash
set -e

TARGET_DISK="/dev/sdb"
# De link naar de allernieuwste Debian 13 Netinst
ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso"

echo "1. Stick ontkoppelen..."
sudo umount ${TARGET_DISK}* 2>/dev/null || true

echo "2. ISO downloaden (Debian 13.4.0)..."
wget -c "$ISO_URL" -O debian-13-netinst.iso

echo "3. Stick volledig wissen..."
sudo wipefs -a "$TARGET_DISK"
sudo dd if=/dev/zero of="$TARGET_DISK" bs=512 count=100 status=none

echo "4. Schrijven naar $TARGET_DISK (Debian 13)..."
sudo dd if=debian-13-netinst.iso of="$TARGET_DISK" bs=4M status=progress oflag=sync

echo "Klaar! Je Debian 13 installatiestick is gereed."
