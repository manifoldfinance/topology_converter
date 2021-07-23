#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
oobmgmtswitchBlock=`sed -n '/DEFINE VM for oob-mgmt-switch/,/DEFINE VM for/p' < Vagrantfile`
echo $oobmgmtswitchBlock | grep 'ATTR{address}=="a0:00:00:00:00:61", NAME="swp1"'
