#!/bin/bash
set -eu

DEFAULT_TIMEZONE=Europe/Berlin
DEFAULT_LANGUAGE_REGION=en:US
DEFAULT_KEYBOARD_LAYOUT_MODEL=us:pc105

show_help()
{
    echo \
"Set timezone, language, region, and keyboard layout.

Usage: $(basename $0) [options]
Options:
    -t <timezone>: Set timezone (default $DEFAULT_TIMEZONE)
    -l <language:region>: Set language and region (default $DEFAULT_LANGUAGE_REGION)
    -k <layout:model>: Set keyboard layout and model (default $DEFAULT_KEYBOARD_LAYOUT_MODEL)"
}

#####################################################################
SCRIPT_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/common.sh

assert_is_root

usage()
{
    show_help 1>&2
    exit 1
}

#####################################################################

SET_TIMEZONE=$DEFAULT_TIMEZONE
SET_LANGUAGE_REGION=$DEFAULT_LANGUAGE_REGION
SET_KEYBOARD_LAYOUT_MODEL=$DEFAULT_KEYBOARD_LAYOUT_MODEL

while getopts "?t:l:k:" o; do
    case "$o" in
        \?)
            show_help
            exit 0
            ;;
        t)
            SET_TIMEZONE=$OPTARG
            ;;
        l)
            SET_LANGUAGE_REGION=$OPTARG
            ;;
        k)
            SET_KEYBOARD_LAYOUT_MODEL=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


assert_is_root

if [ ! -z "$SET_TIMEZONE" ] || [ ! -z "$SET_LANGUAGE_REGION" ] || [ ! -z "$SET_KEYBOARD_LAYOUT_MODEL" ]; then
    install_packages locales tzdata debconf software-properties-common

    if [ ! -z "$SET_TIMEZONE" ]; then
        set_timezone "$SET_TIMEZONE"
    fi

    if [ ! -z "$SET_LANGUAGE_REGION" ]; then
        set_language_region $(echo $SET_LANGUAGE_REGION | tr ":" " ")
    fi

    if [ ! -z "$SET_KEYBOARD_LAYOUT_MODEL" ]; then
        set_keyboard_layout_model $(echo $SET_KEYBOARD_LAYOUT_MODEL | tr ":" " ")
    fi
fi

echo "Region, language, keyboard configured."
