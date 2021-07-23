#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/oob-mgmt-server/d' topology.dot
sed -i '/oob-mgmt-switch/d' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -c
grep "DEFINE VM for oob-mgmt-server" Vagrantfile
grep "DEFINE VM for oob-mgmt-switch" Vagrantfile
