#!/bin/bash
set -ex

# Remove Ansible
sudo rm -rf /etc/ansible/roles/*
sudo apt-get --yes --purge --autoremove remove ansible