#! /bin/sh

ifconfig pflog0 create
/usr/sbin/tcpdump -lnettti pflog0 | /usr/bin/logger -t pflog -p local2.info
