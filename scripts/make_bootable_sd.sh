#!/bin/bash

SD_DEVICE=$1

sudo fdisk $SD_DEVICE <<EOF
a
1
w
EOF

