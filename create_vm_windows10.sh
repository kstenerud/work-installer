#!/bin/bash
set -eu

SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

DEFAULT_MOUNT_DIR="$HOME/windows"
DEFAULT_ISO_DIR="$HOME/iso"
DEFAULT_NAME=windows
DEFAULT_RAM_GB=4
DEFAULT_PROCESSORS=2
DEFAULT_DISK_GB=40

show_help()
{
    echo \
"Install a windows 10 virtual machine.

Usage: $(basename $0) [options]
Options:
    -i <path>: Set the path containing the required ISO files (default $DEFAULT_ISO_DIR)
    -m <path>: Set the path to use for the VM files (default $DEFAULT_MOUNT_DIR)
    -n <name>: Set the name of the virtual machine (default $DEFAULT_NAME)
    -r <gigabytes>: Set the amount of RAM (default $DEFAULT_RAM_GB)
    -d <gigabytes>: Set the disk size (default $DEFAULT_DISK_GB)
    -p <units>: Set the number of processor units (default $DEFAULT_PROCESSORS)"
}

#####################################################################
SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/common.sh


usage()
{
    show_help 1>&2
    exit 1
}

#####################################################################

MOUNT_DIR="$DEFAULT_MOUNT_DIR"
ISO_DIR="$DEFAULT_ISO_DIR"
NAME=$DEFAULT_NAME
RAM_GB=$DEFAULT_RAM_GB
DISK_GB=$DEFAULT_DISK_GB
PROCESSORS=$DEFAULT_PROCESSORS

while getopts "?i:m:n:r:d:p:" o; do
    case "$o" in
        \?)
            show_help
            exit 0
            ;;
        i)
            ISO_DIR=$OPTARG
            ;;
        m)
            MOUNT_DIR=$OPTARG
            ;;
        n)
            NAME=$OPTARG
            ;;
        r)
            RAM_GB=$OPTARG
            ;;
        d)
            DISK_GB=$OPTARG
            ;;
        p)
            PROCESSORS=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


INSTALL_ISO="$ISO_DIR/windows10.iso"
DRIVERS_ISO="$ISO_DIR/virtio-win.iso"

if [ ! -f "$INSTALL_ISO" ]; then
    echo "$INSTALL_ISO not found."
    echo "Please download it from https://www.microsoft.com/en-us/software-download/windows10ISO"
    exit 1
fi

if [ ! -f "$DRIVERS_ISO" ]; then
    echo "$DRIVERS_ISO not found."
    echo "Please download it from https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html#virtio-win-direct-downloads"
    exit 1
fi

if [ ! -d "$MOUNT_DIR" ]; then
    echo "Mount dir $MOUNT_DIR not found. Creating..."
    mkdir -p "$MOUNT_DIR"
fi

$SCRIPT_HOME/virtual-builders/virtual-build windows \
    -b virbr0 \
    -n "$NAME" \
    -m "$MOUNT_DIR" \
    -r $RAM_GB \
    -p $PROCESSORS \
    -d $DISK_GB \
    -I "$INSTALL_ISO" \
    -D "$DRIVERS_ISO"

echo "Windows 10 VM is initializing. Connect VNC client to localhost:5010"
echo "When installing, choose custom install, and browse for drivers in E:/viostor/w10/amd64"
