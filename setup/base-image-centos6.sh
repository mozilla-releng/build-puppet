#! /bin/bash

# parameters

hgrepo="http://hg.mozilla.org/users/dmitchell_mozilla.com/puppet"

# install puppet and wget, using the local mirrors

rm -f /etc/yum.repos.d/*
cat > /etc/yum.repos.d/init.repo <<'EOF'
[epel]
name=epel
baseurl=http://puppet/yum/mirrors/epel/6/latest/$basearch/
enabled=1
gpgcheck=0

[releng-public]
name=releng-public
baseurl=http://puppet/yum/releng/public/noarch
enabled=1
gpgcheck=0

[os]
name=os
baseurl=http://puppet/yum/mirrors/centos/6.0/os/$basearch
enabled=1
gpgcheck=0

[updates]
name=os
baseurl=http://puppet/yum/mirrors/centos/6.0/latest/updates/$basearch
enabled=1
gpgcheck=0
EOF
yum install -y puppet wget || exit 1

# check that puppet is installed properly
if ! puppet --version >/dev/null; then
    echo "Puppet does not appear to be installed properly."
    exit 1
fi

# clean the system up a bit

# save some space
yum clean all || exit 1

# clean history
rm -f /root/.bash_history || exit 1
: > /var/log/messages || exit 1
: > /var/log/wtmp || exit 1

# remove persistent udev rules
rm /etc/udev/rules.d/*persistent*

# remove any existing yum repositories
rm -f /etc/yum.repos.d/*

# kill selinux
cat >/etc/sysconfig/selinux <<EOF
SELINUX=disabled
SELINUXTYPE=targeted 
EOF

# fix up /etc/issue
(
    grep -v '^Base Image' /etc/issue 
    echo "Base Image Date:" `date`
    echo "Base Image OS:" `facter operatingsystem` `facter operatingsystemrelease`
    echo "Base Image Host:" `facter fqdn`
) > /etc/issue~
mv /etc/issue{~,}

# set up for first boot

# TODO...

# finish cleanup

rm -rf /tmp/puppet
#rm -f "$0" # remove this script

echo "Ready to image - halting system"
sleep 2
#/sbin/halt
