#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 /dev/sdX /path/to/boot_dir /path/to/root_dir"
  echo "Where:"
  echo "  /dev/sdX is the device name of your SD card (es. /dev/sdb)"
  echo "  /path/to/boot_dir is the path of the directory containing the boot files"
  echo "  /path/to/root_dir is the path of the directory containing the rootfs.tar"
  exit 1
fi

# Variabili
SD_DEVICE=$1
BOOT_DIR=$2
ROOT_DIR=$3
BOOT_PARTITION="${SD_DEVICE}1"
ROOT_PARTITION="${SD_DEVICE}2"

# Verifica che le cartelle esistano
if [ ! -d "$BOOT_DIR" ]; then
  echo "Error: The directory $BOOT_DIR does not exist."
  exit 1
fi

if [ ! -f "$ROOT_DIR/rootfs.tar" ]; then
  echo "Error: The file $ROOT_DIR/rootfs.tar does not exist."
  exit 1
fi

# Monta le partizioni
echo "Mounting partitions..."
MOUNT_BOOT=$(mktemp -d)
MOUNT_ROOT=$(mktemp -d)
sudo mount $BOOT_PARTITION $MOUNT_BOOT
sudo mount $ROOT_PARTITION $MOUNT_ROOT

# Copia i file nella partizione di boot
echo "Copy of the boot files..."
sudo cp -r $BOOT_DIR/* $MOUNT_BOOT/

# Estrae il filesystem root
echo "Estracting the root filesystem..."
sudo tar -xpf $ROOT_DIR/rootfs.tar -C $MOUNT_ROOT

# Sincronizza e smonta le partizioni
echo "Sync and unmount..."
sync
sudo umount $MOUNT_BOOT
sudo umount $MOUNT_ROOT
rmdir $MOUNT_BOOT $MOUNT_ROOT

echo "Operation completed! Your SD card is ready."
