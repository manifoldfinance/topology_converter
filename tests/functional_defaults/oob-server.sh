#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "oob-mgmt-server" \[function="oob-server"/c\ "oob-mgmt-server" \[function="oob-server"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
oobmgmtserverBlock=`sed -n '/DEFINE VM for oob-mgmt-server/,/DEFINE VM for/p' < Vagrantfile`
echo $oobmgmtserverBlock | grep 'device.vm.box = "generic/ubuntu2004"'
echo $oobmgmtserverBlock | grep 'v.memory = 1024'
