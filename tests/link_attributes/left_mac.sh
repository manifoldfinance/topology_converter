#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
server01Block=`sed -n '/DEFINE VM for server01/,/DEFINE VM for/p' < Vagrantfile`
echo $server01Block | grep 'ATTR{address}=="a0:00:00:00:00:31", NAME="eth0"'
