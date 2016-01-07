#!/usr/bin/env bash

set -evx

SOURCE='http://ftp.us.debian.org/debian/dists/jessie/main/installer-armhf/current/images/netboot/SD-card-images/partition.img.gz'

wget --output-document=- "$SOURCE" | zcat > partition.img
mcopy -i partition.img ::initrd.gz initrd.gz
gunzip initrd.gz
find preseed.cfg | cpio -H newc --create --append --file=initrd --verbose
gzip -9 initrd
mdel -i partition.img ::initrd.gz
mcopy -i partition.img initrd.gz ::initrd.gz
gzip -9 partition.img
