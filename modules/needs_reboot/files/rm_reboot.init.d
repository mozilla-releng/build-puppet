#!/bin/bash
# rm_reboot       Init script removes reboot semaphore
#
# chkconfig: 0123456 00 99
# description: Remove REBOOT_AFTER_PUPPET semaphore.

PATH=/usr/bin:/sbin:/bin:/usr/sbin
export PATH

case "$1" in
    start)
        rm -rf /REBOOT_AFTER_PUPPET
        ;;
    stop)
        exit 0
        ;;
    status)
        exit 0
        ;;
    *)
        echo $"Usage: $0 {start|stop|status}"
        exit 1
esac
