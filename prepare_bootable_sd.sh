#!/bin/bash

ROOTFS_TYPE="null"  # Valore predefinito per rootfs_type
BOOT_TYPE="null"    # Valore predefinito per boot_type
FORMAT_SD=false     # Valore predefinito per formattare la SD card

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 /dev/sdX /path/to/boot_dir /path/to/root_dir [OPTIONS]"
  echo "Where:"
  echo "  /dev/sdX is the device name of your SD card (es. /dev/sdb)"
  echo "  /path/to/boot_dir is the path of the directory containing the boot files"
  echo "  /path/to/root_dir is the path of the directory containing the rootfs.tar"
  echo "Options:"
  echo "  --format: format the SD card before"
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
    --format)
      FORMAT_SD=true
      shift
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

if [ "$FORMAT_SD" = true ]; then
  echo "Formatting SD card..."
  ./scripts/format_sd.sh ${SD_DEVICE}
  if [ $? -ne 0 ]; then
    echo "Errore durante la formattazione della SD card."
    exit 1
  fi
fi

#echo "I valori inseriti in input sono: "
#echo "  SD_DEVICE= $SD_DEVICE"
#echo "  BOOT_DIR= $BOOT_DIR"
#echo "  ROOT_DIR= $ROOT_DIR"
#echo "  FORMAT_SD= $FORMAT_SD"
#echo "  ROOTFS_TYPE= $ROOTFS_TYPE"
#echo "  BOOT_TYPE= $BOOT_TYPE"

./scripts/make_bootable_sd.sh ${SD_DEVICE}

./scripts/load_partitions.sh  ${SD_DEVICE} ${BOOT_DIR} ${ROOT_DIR} --rootfs_type ${ROOTFS_TYPE} --boot_type ${BOOT_TYPE}
