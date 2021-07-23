#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/oob-mgmt-server/d' topology.dot
sed -i '/oob-mgmt-switch/d' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -c
spine01Block=`sed -n '/DEFINE VM for spine01/,/DEFINE VM for/p' < Vagrantfile`
echo $spine01Block | grep 'Vagrant interface = vagrant'
