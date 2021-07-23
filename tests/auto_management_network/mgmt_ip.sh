#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/oob-mgmt-switch/d' topology.dot
sed -i '/^ "oob-mgmt-server" \[function="oob-server"/c\ "oob-mgmt-server" \[function="oob-server" mgmt_ip="10.20.30.254/24"\]' topology.dot
sed -i 's/"leaf01" \[/"leaf01" \[mgmt_ip=10.20.30.250 /' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -c
grep "subnet 10.20.30.0 netmask 255.255.255.0" helper_scripts/auto_mgmt_network/dhcpd.conf
grep "option domain-name-servers 10.20.30.254;" helper_scripts/auto_mgmt_network/dhcpd.conf
grep "option www-server 10.20.30.254;" helper_scripts/auto_mgmt_network/dhcpd.conf
grep 'option default-url = "http://10.20.30.254/onie-installer";' helper_scripts/auto_mgmt_network/dhcpd.conf
if [ $(grep -c 'fixed-address 10.20.30' helper_scripts/auto_mgmt_network/dhcpd.hosts) -ne 15 ]; then
    exit 1
fi
if [ $(grep -c '10.20.30' helper_scripts/auto_mgmt_network/hosts) -ne 16 ]; then
    exit 1
fi
grep 'fixed-address 10.20.30.250; option host-name "leaf01"' helper_scripts/auto_mgmt_network/dhcpd.hosts
