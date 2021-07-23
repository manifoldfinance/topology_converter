#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "server02" \[function="host"/c\ "server02" \[function="fake"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
if grep "DEFINE VM for server02" Vagrantfile; then
    exit 1
fi
grep "link for swp3 --> server02:eth0" Vagrantfile
grep "link for swp2 --> server02:eth1" Vagrantfile
grep "link for swp2 --> server02:eth2" Vagrantfile
