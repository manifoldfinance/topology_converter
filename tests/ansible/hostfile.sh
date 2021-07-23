#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/oob-mgmt-server/d' topology.dot
sed -i '/oob-mgmt-switch/d' topology.dot
sed -i '/^ "leaf01" \[/c\ "leaf01" \[os="CumulusCommunity\/cumulus-vx" vagrant="eth0"\]' topology.dot
sed -i '/^ "spine01" \[/c\ "spine01" \[os="CumulusCommunity\/cumulus-vx" vagrant="eth0"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -a
grep 'ansible.playbook = "./helper_scripts/empty_playbook.yml"' Vagrantfile
grep 'ansible.groups = {' Vagrantfile
ls helper_scripts/empty_playbook.yml
cat helper_scripts/empty_playbook.yml
ls ansible.cfg
cat ansible.cfg
