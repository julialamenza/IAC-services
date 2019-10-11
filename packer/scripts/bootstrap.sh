#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive

# Install Ansible and deps
sudo add-apt-repository --yes ppa:ansible/ansible
sudo apt-get -qq update --yes
sudo apt-get -qq install --yes ansible unzip python-jmespath

# Allow ubuntu to install galaxy roles
sudo chown ubuntu /etc/ansible/roles

# Print version
ansible --version