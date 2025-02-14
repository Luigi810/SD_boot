#!/bin/bash

BOOT_TYPE="null"
ROOTFS_TYPE="tar"

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 /dev/sdX /path/to/boot_dir /path/to/root_dir"
  echo "Where:"
  echo "  /dev/sdX is the device name of your SD card (es. /dev/sdb)"
  echo "  /path/to/boot_dir is the path of the directory containing the boot files"
  echo "  /path/to/root_dir is the path of the directory containing the rootfs.tar"
  echo "Options:"
  echo "  --rootfs_type: to specify the format of the root filesystem (tar, ext4, cpio.gz, null), default is tar"
  echo "  --boot_type: to specify the format to the boot files (tar, null), default is null"
  exit 1
fi

# Parsing degli argomenti
while [[ $# -gt 0 ]]; do
  case "$1" in
    --rootfs_type)
      if [ -n "$2" ]; then
        ROOTFS_TYPE="$2"
        shift 2
      else
        echo "Error: --rootfs_type needs a value."
        usage
      fi
      ;;
    --boot_type)
      if [ -n "$2" ]; then
        BOOT_TYPE="$2"
        shift 2
      else
        echo "Error: --boot_type needs a value."
        usage
      fi
      ;;
    *)
      if [ -z "$SD_DEVICE" ]; then
        SD_DEVICE=$1
      elif [ -z "$BOOT_DIR" ]; then
        BOOT_DIR=$1
      elif [ -z "$ROOT_DIR" ]; then
        ROOT_DIR=$1
      else
        echo "Error: Too many arguments."
        usage
      fi
      shift
      ;;
  esac
done


BOOT_PARTITION="${SD_DEVICE}1"
ROOT_PARTITION="${SD_DEVICE}2"

# Verifica che le cartelle esistano
if [ ! -d "$BOOT_DIR" ]; then
  echo "Error: The directory $BOOT_DIR does not exist."
  exit 1
fi


if [ ! -d "$ROOT_DIR" ]; then
  echo "Error: The directory $ROOT_DIR does not exist."
  exit 1
fi

# Monta le partizioni
echo "Mounting partitions..."
MOUNT_BOOT=$(mktemp -d)
MOUNT_ROOT=$(mktemp -d)
sudo mount $BOOT_PARTITION $MOUNT_BOOT
sudo mount $ROOT_PARTITION $MOUNT_ROOT

# Gestione del boot
case "$BOOT_TYPE" in
  null)
    echo "Copy of the boot files (not compressed)..."
    sudo cp -r $BOOT_DIR/* $MOUNT_BOOT/
    ;;
  tar)
    echo "Estracting partition tar archive..."
    sudo tar -xpf $BOOT_DIR/boot.tar -C $MOUNT_BOOT
    ;;
  *)
    echo "Error: boot_type format not supported: $BOOT_TYPE"
    exit 1
    ;;
esac

# Gestione del rootfs
case "$ROOTFS_TYPE" in
  null)
    echo "Copy of the root filesystem (not compressed)..."
    sudo cp -r $ROOT_DIR/* $MOUNT_ROOT/
    ;;
  tar)
    echo "Estracting partition tar archive..."
    sudo tar -xpf $ROOT_DIR/rootfs.tar -C $MOUNT_ROOT
    ;;
  ext4)
    echo "Copy ext4 image in root filesystem partition..."
    sudo dd if=$ROOT_DIR/rootfs.ext4 of=$ROOT_PARTITION bs=4M status=progress
    ;;
  cpio.gz)
    #Caso ancora da verificare
    echo "Estracting partition cpio.gz archive..."
    zcat $ROOT_DIR/rootfs.cpio.gz | sudo cpio -idm -D $MOUNT_ROOT
    ;;
  *)
    echo "Error: rootfs_type format not supported: $ROOTFS_TYPE"
    exit 1
    ;;
esac


# Sincronizza e smonta le partizioni
echo "Sync and unmount..."
sync
sudo umount $MOUNT_BOOT
sudo umount $MOUNT_ROOT
rmdir $MOUNT_BOOT $MOUNT_ROOT

echo "Operation completed! Your SD card is ready."
