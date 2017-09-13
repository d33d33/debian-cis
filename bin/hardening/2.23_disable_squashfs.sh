#!/bin/bash

#
# CIS Debian 7/8 Hardening
#

#
# 2.23 Disable Mounting of squashfs Filesystems (Not Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

KERNEL_OPTION="CONFIG_SQUASHFS"
MODULE_FILE="squashfs"
FILE='/etc/modprobe.d/blacklist.conf'


# This function will be called if the script status is on enabled / audit mode
audit () {
    is_kernel_option_enabled $KERNEL_OPTION $MODULE_FILE
    if [ $FNRET = 0 ]; then # 0 means true in bash, so it IS activated
        crit "$KERNEL_OPTION is enabled!"
    else
        ok "$KERNEL_OPTION is disabled"
    fi
    :
}

# This function will be called if the script status is on enabled mode
apply () {
    is_kernel_option_enabled $KERNEL_OPTION
    if [ $FNRET = 0 ]; then # 0 means true in bash, so it IS activated
        warn "$KERNEL_OPTION is enabled!"
        touch $FILE
        chmod 644 $FILE
        add_end_of_file $FILE "blacklist $KERNEL_OPTION"
    else
        ok "$KERNEL_OPTION is disabled, nothing to do"
    fi
    :
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ ! -r /etc/default/cis-hardening ]; then
    echo "There is no /etc/default/cis-hardening file, cannot source CIS_ROOT_DIR variable, aborting"
    exit 128
else
    . /etc/default/cis-hardening
    if [ -z ${CIS_ROOT_DIR:-} ]; then
        echo "No CIS_ROOT_DIR variable, aborting"
        exit 128
    fi
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r $CIS_ROOT_DIR/lib/main.sh ]; then
    . $CIS_ROOT_DIR/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
