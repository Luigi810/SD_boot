#!/bin/bash

# Verifica che l'utente abbia fornito il dispositivo della SD card come argomento
if [ -z "$1" ]; then
  echo "Usage: $0 /dev/sdX"
  echo "where /dev/sdX is the device name of your SD card (es. /dev/sdb)."
  exit 1
fi

# Variabili
SD_DEVICE=$1
BOOT_PARTITION="${SD_DEVICE}1"
ROOT_PARTITION="${SD_DEVICE}2"

# Conferma prima di procedere
echo "WARNING: All the data on $SD_DEVICE will be lost!"
read -p "Are you sure to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Operation cancelled."
  exit 1
fi

# Formatta la SD card con fdisk
echo "Formatting SD card..."
sudo umount ${SD_DEVICE}* 2>/dev/null
sudo fdisk $SD_DEVICE <<EOF
o
n
p
1

+1G
n
p
2


t
1
c
w
EOF

# Crea i filesystem
echo "Creation of FAT32 filesystem for the boot partition..."
sudo mkfs.vfat -F 32 -n BOOT $BOOT_PARTITION

echo "Creation of ext4 filesystem for the root partition..."
sudo mkfs.ext4 -L ROOT $ROOT_PARTITION

echo "Completed! Partitions are now ready."
