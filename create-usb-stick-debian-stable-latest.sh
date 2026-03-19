#!/bin/bash
set -e

# Variabelen
TARGET_DISK="/dev/sdb"
# Deze URL bevat altijd de metadata van de huidige stabiele release
BASE_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/"

echo "1. Zoeken naar de nieuwste stable ISO-naam..."
# Haal de bestandsnaam op die eindigt op netinst.iso uit de mappenlijst
ISO_NAME=$(wget -qO- $BASE_URL | grep -oP 'debian-[0-9.]+-amd64-netinst.iso' | head -n 1)

if [ -z "$ISO_NAME" ]; then
    echo "Fout: Kon de nieuwste ISO-naam niet vinden op de Debian server."
    exit 1
fi

ISO_URL="${BASE_URL}${ISO_NAME}"
echo "Gevonden: $ISO_NAME"

echo "2. Stick $TARGET_DISK ontkoppelen..."
sudo umount ${TARGET_DISK}* 2>/dev/null || true

echo "3. Downloaden van $ISO_NAME..."
wget -c "$ISO_URL" -O "debian-stable-latest.iso"

echo "4. Stick volledig wissen (wipefs)..."
sudo wipefs -a "$TARGET_DISK"
sudo dd if=/dev/zero of="$TARGET_DISK" bs=512 count=100 status=none

echo "5. Schrijven naar $TARGET_DISK (status wordt getoond)..."
sudo dd if="debian-stable-latest.iso" of="$TARGET_DISK" bs=4M status=progress oflag=sync

echo "---"
echo "Klaar! Je hebt nu de allernieuwste Debian Stable ($ISO_NAME) op je stick."
