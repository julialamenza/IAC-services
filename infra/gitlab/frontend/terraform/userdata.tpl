#!/bin/bash
set -xe

sleep 30

###################### EBS #####################################################

DEVICE_TYPE=`blkid -s TYPE -o value ${device_name} || true`
if [[ "$DEVICE_TYPE" != "ext4" ]]; then
  mkfs.ext4 ${device_name}
fi

mkdir -pv /var/opt/gitlab
MOUNT_LINE='${device_name} /var/opt/gitlab ext4 defaults,auto 0 0'
grep -q -F "$MOUNT_LINE" /etc/fstab || echo "$MOUNT_LINE" >> /etc/fstab
mount /var/opt/gitlab

# chown gitlab: -R /opt/gitlab

###################### GITLAB VARS #####################################################
# REDIS
# POSTGRES
sed -i -- "s#__DATABASE_HOST__#gitlab-database.ckjw36ahc7px.eu-west-3.rds.amazonaws.com#"   /etc/gitlab/gitlab.rb
sed -i -- "s#__DATABASE_PORT__#5432#"   /etc/gitlab/gitlab.rb
sed -i -- "s#__DATABASE_USERNAME__#gitlabmaster#"   /etc/gitlab/gitlab.rb
sed -i -- "s#__DATABASE_PASSWORD__#corum2019#"   /etc/gitlab/gitlab.rb
# HOSTNAME
sed -i -- "s#__EXTERNAL_URL__#http://alb-gitlab-server-5d28a6d16ba9f2e0.elb.eu-west-3.amazonaws.com#"   /etc/gitlab/gitlab.rb


###################### GITLAB START #####################################################
systemctl start gitlab-runsvdir.service
systemctl enable gitlab-runsvdir.service
gitlab-ctl restart
gitlab-ctl reconfigure