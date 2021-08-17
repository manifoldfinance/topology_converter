#!/usr/bin/env python3
"""
Topology Converter
    converts a given topology.dot file to a Vagrantfile
    can use the virtualbox or libvirt Vagrant providers
Initially written by Eric Pulvino 2015-10-19

hosted @ https://gitlab.com/cumulus-consulting/tools/topology_converter
"""
# pylint: disable=print-function,global-statement

import os
import sys

import argparse
import ipaddress

from topology_converter.tc_config import TcConfig # pylint: disable=no-name-in-module
from topology_converter.tc_error import RenderError, TcError # pylint: disable=no-name-in-module
from topology_converter.parse_topology import parse_topology # pylint: disable=no-name-in-module
from topology_converter.renderer import Renderer # pylint: disable=no-name-in-module
from topology_converter.styles import styles # pylint: disable=no-name-in-module
from topology_converter.warning_messages import WarningMessages # pylint: disable=no-name-in-module

VERSION = '4.7.1'

PARSER = argparse.ArgumentParser(description='Topology Converter -- Convert \
                                 topology.dot files into Vagrantfiles')
PARSER.add_argument('topology_file',
                    help='provide a topology file as input')
PARSER.add_argument('-v', '--verbose', action='count', default=0,
                    help='increases logging verbosity (repeat for more verbosity (3 max))')
PARSER.add_argument('-p', '--provider', choices=['libvirt', 'virtualbox'],
                    help='specifies the provider to be used in the Vagrantfile, \
                    script supports "virtualbox" or "libvirt", default is virtualbox.')
PARSER.add_argument('-a', '--ansible-hostfile', action='store_true',
                    help='When specified, ansible hostfile will be generated \
                    from a dummy playbook run.')
PARSER.add_argument('-c', '--create-mgmt-network', action='store_true',
                    help='When specified, a mgmt switch and server will be created. \
                    A /24 is assumed for the mgmt network. mgmt_ip=X.X.X.X will be \
                    read from each device to create a Static DHCP mapping for \
                    the oob-mgmt-server.')
PARSER.add_argument('-cco', '--create-mgmt-configs-only', action='store_true',
                    help='Calling this option does NOT regenerate the Vagrantfile \
                    but it DOES regenerate the configuration files that come \
                    packaged with the mgmt-server in the "-c" option. This option \
                    is typically used after the "-c" has been called to generate \
                    a Vagrantfile with an oob-mgmt-server and oob-mgmt-switch to \
                    modify the configuraiton files placed on the oob-mgmt-server \
                    device. Useful when you do not want to regenerate the \
                    vagrantfile but you do want to make changes to the \
                    OOB-mgmt-server configuration templates.')
PARSER.add_argument('-cmd', '--create-mgmt-device', action='store_true',
                    help='Calling this option creates the mgmt device and runs the \
                    auto_mgmt_network template engine to load configurations on to \
                    the mgmt device but it does not create the OOB-MGMT-SWITCH or \
                    associated connections. Useful when you are manually specifying \
                    the construction of the management network but still want to have \
                    the OOB-mgmt-server created automatically.')
PARSER.add_argument('-t', '--template', action='append', nargs=2,
                    help='Specify an additional jinja2 template and a destination \
                    for that file to be rendered to.')
PARSER.add_argument('-i', '--tunnel-ip',
                    help='FOR LIBVIRT PROVIDER: this option overrides the tunnel_ip \
                    setting for all nodes. This option provides another method of \
                    udp port control in that all ports are bound to the specified \
                    ip address. Specify "random" to use a random localhost IP.')
PARSER.add_argument('-s', '--start-port', type=int,
                    help='FOR LIBVIRT PROVIDER: this option overrides \
                    the default starting-port 8000 with a new value. \
                    Use ports over 1024 to avoid permissions issues. If using \
                    this option with the virtualbox provider it will be ignored.')
PARSER.add_argument('-g', '--port-gap', type=int,
                    help='FOR LIBVIRT PROVIDER: this option overrides the \
                    default port-gap of 1000 with a new value. This number \
                    is added to the start-port value to determine the port \
                    to be used by the remote-side. Port-gap also defines the \
                    max number of links that can exist in the topology. EX. \
                    If start-port is 8000 and port-gap is 1000 the first link \
                    will use ports 8001 and 9001 for the construction of the \
                    UDP tunnel. If using this option with the virtualbox \
                    provider it will be ignored.')
PARSER.add_argument('-dd', '--display-datastructures', action='store_true',
                    help='When specified, the datastructures which are passed \
                    to the template are displayed to screen. Note: Using \
                    this option does not write a Vagrantfile and \
                    supercedes other options.')
PARSER.add_argument('--synced-folder', action='store_true',
                    help='Using this option enables the default Vagrant \
                    synced folder which we disable by default. \
                    See: https://www.vagrantup.com/docs/synced-folders/basic_usage.html')
PARSER.add_argument('--version', action='version', version='Topology \
                    Converter version is v%s' % VERSION,
                    help='Using this option displays the version of Topology Converter')
PARSER.add_argument('--prefix', help='Specify a prefix to be used for machines in libvirt. \
                    By default the name of the current folder is used.')
ARGS = PARSER.parse_args()

# Parse Arguments
TC_CONFIG = TcConfig(**ARGS.__dict__)
TC_CONFIG.parser = PARSER
TC_CONFIG.version = VERSION
NETWORK_FUNCTIONS = TC_CONFIG.network_functions
FUNCTION_GROUP = TC_CONFIG.function_group
PROVIDER = TC_CONFIG.provider
GENERATE_ANSIBLE_HOSTFILE = TC_CONFIG.ansible_hostfile
CREATE_MGMT_DEVICE = TC_CONFIG.create_mgmt_device
CREATE_MGMT_NETWORK = TC_CONFIG.create_mgmt_network
CREATE_MGMT_CONFIGS_ONLY = TC_CONFIG.create_mgmt_configs_only
VERBOSE = TC_CONFIG.verbose
TUNNEL_IP = TC_CONFIG.tunnel_ip
START_PORT = TC_CONFIG.start_port
PORT_GAP = TC_CONFIG.port_gap
SYNCED_FOLDER = TC_CONFIG.synced_folder
DISPLAY_DATASTRUCTURES = TC_CONFIG.display_datastructures
ARG_STRING = TC_CONFIG.arg_string
LIBVIRT_PREFIX = TC_CONFIG.prefix
VAGRANT = TC_CONFIG.vagrant

TOPOLOGY_FILE = TC_CONFIG.topology_file

# Determine whether local or global helper_scripts will be used.
if os.path.isdir('./helper_scripts'):
    TC_CONFIG.script_storage = './helper_scripts'
else:
    TC_CONFIG.script_storage = TC_CONFIG.relpath_to_me+'/helper_scripts'
SCRIPT_STORAGE = TC_CONFIG.script_storage

if CREATE_MGMT_DEVICE or ARGS.create_mgmt_configs_only:
    TC_CONFIG.vagrant = 'vagrant'

if CREATE_MGMT_NETWORK:
    TC_CONFIG.vagrant = 'vagrant'
    TC_CONFIG.create_mgmt_device = True
    CREATE_MGMT_DEVICE = True

if ARGS.template:
    for templatefile, destination in ARGS.template:
        TC_CONFIG.templates.append([templatefile, destination])

for templatefile, destination in TC_CONFIG.templates:
    if not os.path.isfile(templatefile):
        print(styles.FAIL + styles.BOLD + ' ### ERROR: provided template file-- "' +
              templatefile + '" does not exist!' + styles.ENDC)
        sys.exit(1)

if TUNNEL_IP:
    if PROVIDER == 'libvirt':
        TUNNEL_IP = ARGS.tunnel_ip
        if TUNNEL_IP != 'random':
            try:
                ipaddress.ip_address(TUNNEL_IP)
            except ValueError as err:
                print(styles.FAIL + styles.BOLD + ' ### ERROR: ' + str(err) + '.'
                      + ' Specify \'random\' to use a random localhost IPv4 address.'
                      + styles.ENDC)
                sys.exit(1)
    else:
        print(styles.FAIL + styles.BOLD + ' ### ERROR: tunnel IP was specified but ' +
              'provider is not libvirt.' + styles.ENDC)
        sys.exit(1)

if VERBOSE > 2:
    print('Arguments:')
    print(ARGS)

if VERBOSE > 2:
    print('relpath_to_me: {}'.format(TC_CONFIG.relpath_to_me))

###################################
#### MAC Address Configuration ####
###################################

# The starting MAC for assignment for any devices not in mac_map
# Cumulus Range ( 44:38:39:ff:00:00 - 44:38:39:ff:ff:ff )
TC_CONFIG.start_mac = '443839000000'

# This file is generated to store the mapping between macs and interfaces
DHCP_MAC_FILE = './dhcp_mac_map'

######################################################
#############    Everything Else     #################
######################################################

# Hardcoded Variables
MAC_MAP = TC_CONFIG.mac_map
WARNING = WarningMessages()

# Static Variables -- Do not change!
LIBVIRT_REUSE_ERROR = '''
       When constructing a VAGRANTFILE for the libvirt provider
       interface reuse is not possible because the UDP tunnels
       which libvirt uses for communication are point-to-point in
       nature. It is not possible to create a point-to-multipoint
       UDP tunnel!

       NOTE: Perhaps adding another switch to your topology would
       allow you to avoid reusing interfaces here.
'''

###### Functions
def remove_generated_files():
    """
    Removes files previously generated by topology_converter.py
    """
    if DISPLAY_DATASTRUCTURES:
        return
    if VERBOSE > 2:
        print('Removing existing DHCP FILE...')
    if os.path.isfile(DHCP_MAC_FILE):
        os.remove(DHCP_MAC_FILE)


def generate_dhcp_mac_file(mac_map):
    """
    Generates the DHCP MAC mapping file
    """
    if VERBOSE > 2:
        print('GENERATING DHCP MAC FILE...')

    mac_file = open(DHCP_MAC_FILE, 'a')

    if '' in mac_map:
        del mac_map['']

    dhcp_display_list = []

    for line in mac_map:
        dhcp_display_list.append(mac_map[line] + ',' + line)

    dhcp_display_list.sort()

    for line in dhcp_display_list:
        mac_file.write(line + '\n')

    mac_file.close()


def generate_ansible_files():
    """
    Generates an empty playbook and ansible.cfg
    """
    if not GENERATE_ANSIBLE_HOSTFILE:
        return

    if VERBOSE > 2:
        print('Generating Ansible Files...')

    with open(SCRIPT_STORAGE+'/empty_playbook.yml', 'w') as playbook:
        playbook.write('''---
- hosts: all
  user: vagrant
  gather_facts: no
  tasks:
    - command: "uname -a"
''')

    with open('./ansible.cfg', 'w') as ansible_cfg:
        ansible_cfg.write('''[defaults]
inventory = ./.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
hostfile= ./.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
host_key_checking=False
callback_whitelist = profile_tasks
jinja2_extensions=jinja2.ext.do''')


def main():
    """
    Main
    """
    global MAC_MAP
    print(styles.HEADER + '\n######################################')
    print(styles.HEADER + '          Topology Converter')
    print(styles.HEADER + '######################################')
    print(styles.BLUE + '           originally written by Eric Pulvino')

    try:
        inventory = parse_topology(TOPOLOGY_FILE, TC_CONFIG)
    except TcError:
        sys.exit(1)

    renderer = Renderer(TC_CONFIG)
    devices = renderer.populate_data_structures(inventory)

    remove_generated_files()

    try:
        renderer.render_jinja_templates(devices)
    except RenderError as err:
        print(styles.FAIL + styles.BOLD + str(err.message) + styles.ENDC)
        sys.exit(1)
    if DISPLAY_DATASTRUCTURES:
        sys.exit(0)

    generate_dhcp_mac_file(MAC_MAP)

    generate_ansible_files()

    if CREATE_MGMT_CONFIGS_ONLY:
        print(styles.GREEN + styles.BOLD + '\n############\nSUCCESS: MGMT Network Templates have \
              been regenerated!\n############' + styles.ENDC)
    else:
        print(styles.GREEN + styles.BOLD +
              '\n############\nSUCCESS: Vagrantfile has been generated!\n############' +
              styles.ENDC)
        print(styles.GREEN + styles.BOLD +
              '\n            %s devices under simulation.' % (len(devices)) +
              styles.ENDC)

        for device in inventory:
            print(styles.GREEN + styles.BOLD +
                  '                %s' % (inventory[device]['hostname']) +
                  styles.ENDC)
        print(styles.GREEN + styles.BOLD +
              '\n            Requiring at least %s MBs of memory.' % (TC_CONFIG.total_memory) +
              styles.ENDC)


    WARNING.print_warnings()

    print('\nDONE!\n')


if __name__ == '__main__':
    main()

sys.exit(0)
