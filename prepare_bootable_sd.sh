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

./scripts/format_sd.sh ${SD_DEVICE}

./scripts/make_bootable_sd.sh ${SD_DEVICE}

./scripts/load_partitions.sh  ${SD_DEVICE} ${BOOT_DIR} ${ROOT_DIR}
