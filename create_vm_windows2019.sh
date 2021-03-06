#!/bin/bash
set -eu

SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

DEFAULT_MOUNT_DIR="$HOME/win2019"
DEFAULT_ISO_DIR="$HOME/iso"
DEFAULT_NAME=win2019
DEFAULT_RAM_GB=10
DEFAULT_PROCESSORS=2
DEFAULT_DISK_GB=100

show_help()
{
    echo \
"Install a windows server 2019 virtual machine.

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


INSTALL_ISO="$ISO_DIR/windows2019.iso"
DRIVERS_ISO="$ISO_DIR/virtio-win.iso"

if [ ! -f "$INSTALL_ISO" ]; then
    echo "$INSTALL_ISO not found."
    echo "Please download it from https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019"
    echo "Last good image: https://software-download.microsoft.com/download/sg/17763.107.101029-1455.rs5_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso"
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

echo "Windows 10 VM is initializing. Connect VNC client to localhost:5910"
echo
echo "* If you don't have a product key yet, choose \"I don't have a product key\"."
echo "* For install type, choose \"Custom: Install Windows Only\"."
echo "* It won't find any drive to install. Click \"Load Driver\", \"Browse\", and look in E:/viostor/w10/amd64"
echo "* For set up type, choose \"Set up for personal use\""
echo "* Do not sign in with Microsoft. Instead, click \"Offline account\" in the bottom left corner, then select \"No\" when it asks to use a Microsoft account anyway."
echo "* All of the features it asks to enable can remain disabled."
echo
echo "Once the OS install is complete, install E:\\guest-agent\\qemu-ga-x64.exe, then open Device Manager to install any missing drivers"

