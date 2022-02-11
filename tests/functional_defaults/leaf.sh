#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "leaf01" \[function="leaf"/c\ "leaf01" \[function="leaf"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
leafBlock=`sed -n '/DEFINE VM for leaf01/,/DEFINE VM for/p' < Vagrantfile`
echo $leafBlock | grep 'device.vm.box = "CumulusCommunity/cumulus-vx"'
echo $leafBlock | grep 'v.memory = 768'
echo $leafBlock | grep '/etc/ptm.d/topology.dot'
