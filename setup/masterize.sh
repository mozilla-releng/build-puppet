#!/bin/bash
set -e
set -x

echo "Setting up this host to be a puppet master"
# TODO: wget this script, clone the repo, run it

MYHOSTNAME=`hostname -s`
MYFQDN=`hostname`
if [ "$MYHOSTNAME" == "$MYFQDN" ]; then
  echo "This host doesn't have a fqdn set. That will break ssl stuff. Please run \`hostname <fqdn>\` and run this script again."
  exit 1
fi
correctmatch=`grep $MYFQDN /etc/sysconfig/network || exit 0`
if [ -z "$correctmatch" ]; then
  echo "=== Fixing incorrect hostname in /etc/sysconfig/network"
  sed -i "s/^HOSTNAME=.*/HOSTNAME=$MYFQDN/" /etc/sysconfig/network
fi


/bin/echo "=== Setting up yum repositories..."
/bin/rm -f /etc/yum.repos.d/*
/bin/cp /etc/puppet/production/setup/yum-bootstrap.repo /etc/yum.repos.d
/bin/cp /etc/puppet/production/setup/hosts-bootstrap /etc/hosts
/bin/echo "127.0.0.1 $MYFQDN" >> /etc/hosts

/bin/echo "=== Cleaning up yum ==="
/usr/bin/yum clean all

/bin/echo "=== Installing apache, setting up mirrors ==="
(/bin/rpm -q httpd  > /dev/null 2>&1 || /usr/bin/yum -y -q install httpd)
/bin/cp /etc/puppet/production/modules/puppetmaster/files/yum_mirrors.conf /etc/httpd/conf.d/yum_mirrors.conf
/etc/init.d/httpd restart

echo "=== Ensuring clock is set correctly..."
if ( `ps ax | grep -v grep | grep -q ntpd` ); then
    # Stop ntpd running. Puppet will start it back up
    /sbin/service ntpd stop
fi
/usr/sbin/ntpdate ntp.build.mozilla.org

/bin/echo "=== Installing puppet-server... ==="

(/bin/rpm -q puppet  > /dev/null 2>&1 || /usr/bin/yum -y -q install puppet)
if [ ! -d /var/lib/puppet/ssl ]; then
    # generate initial certs to allow apache start properly
    (/bin/rpm -q puppet-server > /dev/null 2>&1 || /usr/bin/yum -y -q install puppet-server)
    /sbin/service puppetmaster restart
    /sbin/service puppetmaster stop
fi

/usr/bin/puppet apply --modulepath /etc/puppet/production/modules \
    --manifestdir /etc/puppet/production/manifests \
    --detailed-exitcodes \
    /etc/puppet/production/manifests/site.pp
