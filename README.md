# Scripts to format and load an SD card
A set of Bash scripts to prepare a bootable SD card or USB key for a generic board. The scripts can be executed without any installation end there is a breif usage guide if any script is used with not enough arguments. 
The tool is divided in 3 scripts contained in the scripts directory and are invoked by the driver-script prepare_bootable_sd.sh if there are the needed flags.
The prepare_bootable_sd.sh takes as input an SD device and 2 directories which contain the content of the desired partitions (the convention wants separated files for the partitions), than can 
- format the device and create a bootable partition fat32 of size 1GB and a second partition ext4 of the remaning size on the device,
- if needed extract the archive boot.* (where * has to be the archive-format specified by a flag, default is raw content) related to the BOOT partition and then load the contents in the BOOT partition of the device
- if needed extract the archive rootfs.* (where * has to be the archive-format specified by a flag, default is tar) related to the ROOT partition and then load the contents in the ROOT partition of the device

# Future Updates
* Extraction of the sd image from a single file/archive using dd to load it on the device
* Flags to allow other partition formats for the device (currently only FAT32 for boot partition and ext4 for rootfs partition)
* Flags to allow different partition sizes and also number of partitions
