#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/oob-mgmt-switch/d' topology.dot
sed -i '/^ "oob-mgmt-server" \[function="oob-server"/c\ "oob-mgmt-server" \[function="oob-server"\]' topology.dot
sed -i 's/"leaf01" \[/"leaf01" \[ssh_user="gitlabciuser" /' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -c
grep "leaf01" -A 1 helper_scripts/auto_mgmt_network/ssh_config | grep "gitlabciuser"
