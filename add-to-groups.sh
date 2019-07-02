#!/bin/bash
set -eu

SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/common.sh

USER=$1

assert_is_root

add_user_to_groups $USER adm sudo lxd libvirt docker
