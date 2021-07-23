#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i 's/"leaf01" \[/"leaf01" \[tunnel_ip="10.20.30.40" /' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
leaf01Block=`sed -n '/DEFINE VM for leaf01/,/DEFINE VM for/p' < Vagrantfile`
if [ $(grep -c '10.20.30.40' Vagrantfile) -ne 22 ]; then
    exit 1
fi
# This should be updated to check for the IPs just in the block for leaf01, but the below wasn't working
#    - if [ $(echo $leaf01Block \| grep '10.20.30.40') -ne 20 ]; then exit 1; fi
