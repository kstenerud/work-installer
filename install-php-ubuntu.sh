#!/bin/bash
set -eu

SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/common.sh

install_php_ubuntu
