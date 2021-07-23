#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
spine01Block=`sed -n '/DEFINE VM for spine01/,/DEFINE VM for/p' < Vagrantfile`
echo $spine01Block | grep 'Vagrant interface = eth0'
