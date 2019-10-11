#!/bin/bash
set -xe

sleep 30

/opt/bitnami/ctlscript.sh stop mongodb

DEVICE_TYPE=`blkid -s TYPE -o value ${device_name} || true`
if [[ "$DEVICE_TYPE" != "ext4" ]]; then
  mkfs.ext4 ${device_name}
fi

mkdir -pv /opt/bitnami/mongodb/data
MOUNT_LINE='${device_name} /opt/bitnami/mongodb/data ext4 defaults,auto 0 0'
grep -q -F "$MOUNT_LINE" /etc/fstab || echo "$MOUNT_LINE" >> /etc/fstab
mount /opt/bitnami/mongodb/data

/opt/bitnami/ctlscript.sh start mongodb
