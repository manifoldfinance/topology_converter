#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "oob-mgmt-server" \[function="oob-server"/c\ "oob-mgmt-server" \[function="oob-server" custom_dns_servers="1.2.3.4 5.6.7.8"\]' topology.dot
sed -i '/oob-mgmt-switch/d' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -c
grep "DNS=1.2.3.4 5.6.7.8" helper_scripts/auto_mgmt_network/OOB_Server_Config_auto_mgmt.sh
