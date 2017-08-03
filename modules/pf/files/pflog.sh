#! /bin/sh

ifconfig pflog0 create
/usr/sbin/tcpdump -lnettti pflog0 2> /dev/null | /usr/bin/logger -t pflog -p local2.info
