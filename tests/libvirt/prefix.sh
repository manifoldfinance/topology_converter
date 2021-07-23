#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt --prefix GITLABCI
grep "libvirt.default_prefix = 'GITLABCI'" Vagrantfile
