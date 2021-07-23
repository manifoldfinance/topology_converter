#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "internet" \[function="internet"/c\ "internet" \[function="internet"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
internetBlock=`sed -n '/DEFINE VM for internet/,/DEFINE VM for/p' < Vagrantfile`
echo $internetBlock | grep 'device.vm.box = "CumulusCommunity/cumulus-vx"'
echo $internetBlock | grep 'v.memory = 768'
