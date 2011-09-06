#! /bin/bash

# parameters

hgrepo="http://hg.mozilla.org/users/dmitchell_mozilla.com/puppet"

# kill selinux, as it won't let anything start
if selinuxenabled; then
    cat >/etc/sysconfig/selinux <<EOF
SELINUX=disabled
SELINUXTYPE=targeted 
EOF
    echo "selinux is enabled; you must reboot now to disable it, and login via SSH"
    exit 1
fi

# install puppet and a few other things for setup, using the local mirrors

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

# puppet: that's why we're here
# wget: used below
# openssh-clients: puppetize.sh uses ssh
# ntp: to synchronize time so certificates work
yum install -y puppet wget openssh-clients ntp || exit 1

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
rm /etc/udev/rules.d/*persistent* || echo '  (ignored)'

# remove any existing yum repositories
rm -f /etc/yum.repos.d/*

# fix up /etc/issue
(
    grep -v '^Base Image' /etc/issue 
    echo "Base Image Date:" `date`
    echo "Base Image OS:" `facter operatingsystem` `facter operatingsystemrelease`
    echo "Base Image Host:" `facter fqdn`
) > /etc/issue~
mv /etc/issue{~,}

# set up for first boot

# get the deploy key
echo "NOTE: you will need to use an SSH agent with a root key on the puppet server!"
scp root@puppet:/etc/puppet/deploykey /root/deploykey || exit 1

# set up the puppetize script to run at boot
wget -O/root/puppetize.sh "$hgrepo/raw-file/tip/setup/puppetize.sh" || exit 1
chmod +x /root/puppetize.sh
(
    grep -v puppetize /etc/rc.local
    echo '/bin/bash /root/puppetize.sh'
) > /etc/rc.d/rc.local~
mv /etc/rc.d/rc.local{~,}
chmod +x /etc/rc.d/rc.local

# finish cleanup
rm "$0"

echo "Ready to image - halting system"
sleep 2
/sbin/halt
