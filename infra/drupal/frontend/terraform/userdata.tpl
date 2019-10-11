#!/bin/bash
set -xe

###################### EBS #####################################################

systemctl stop nexus

sleep 100

DEVICE_TYPE=`blkid -s TYPE -o value ${device_name} || true`
if [[ "$DEVICE_TYPE" != "ext4" ]]; then
  mkfs.ext4 ${device_name}
fi

mkdir -pv /var/nexus
MOUNT_LINE='${device_name} /var/nexus ext4 defaults,auto 0 0'
grep -q -F "$MOUNT_LINE" /etc/fstab || echo "$MOUNT_LINE" >> /etc/fstab
mount /var/nexus

chown nexus: -R /var/nexus

systemctl start nexus
