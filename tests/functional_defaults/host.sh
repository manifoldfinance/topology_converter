#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "server01" \[function="host"/c\ "server01" \[function="host"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
hostBlock=`sed -n '/DEFINE VM for server01/,/DEFINE VM for/p' < Vagrantfile`
echo $hostBlock | grep 'device.vm.box = "generic/ubuntu1804"'
echo $hostBlock | grep 'v.memory = 512'
echo $hostBlock | grep -v '/etc/ptm.d/topology.dot'
