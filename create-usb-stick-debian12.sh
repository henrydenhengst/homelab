#!/bin/bash
set -e

TARGET_DISK="/dev/sdb"
# De exacte link naar de laatste Debian 12 (Oldstable)
ISO_URL="https://cdimage.debian.org/cdimage/archive/12.13.0/amd64/iso-cd/debian-12.13.0-amd64-netinst.iso"

echo "1. Stick ontkoppelen en vrijgeven..."
# Cinnamon/Gnome mounten sticks vaak automatisch; dit gooit ze eraf.
sudo umount ${TARGET_DISK}* 2>/dev/null || true

echo "2. ISO downloaden (Debian 12.13)..."
wget -c "$ISO_URL" -O debian-12-netinst.iso

echo "3. Stick opschonen..."
sudo wipefs -a "$TARGET_DISK"
# Schrijf een beetje 'zeroes' om de partitietabel echt te mollen
sudo dd if=/dev/zero of="$TARGET_DISK" bs=512 count=100 status=none

echo "4. ISO schrijven naar $TARGET_DISK..."
sudo dd if=debian-12-netinst.iso of="$TARGET_DISK" bs=4M status=progress oflag=sync

echo "Klaar! Je Debian 12.13 stick is klaar."
