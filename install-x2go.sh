#!/bin/bash
set -eu

#####################################################################
SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/common.sh "$SCRIPT_HOME"

show_after_help()
{
    echo "SSH Password authentication might be disabled by default. To enable it:"
    echo "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
    echo "systemctl restart sshd"
    echo
}

install_crd()
{
    install_packages \
        x2goserver \
        x2goserver-xsession \
        x2goclient

    show_after_help
}

#####################################################################

install_crd
