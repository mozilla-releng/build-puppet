#! /bin/bash

# Supported distros/os's:
#  - CentOS 6.0
# remember, you can use facter to make this generic

clear
echo "This script will reset this system to its state as a base image, ready to"
echo "be captured.  This assumes the system was just installed from media, and"
echo "has puppet installed."
echo ""
echo "When this script finishes, the host will be stopped.  When it is started"
echo "again, it will try to re-puppetize itself."
echo ""
echo -n "Do you want to proceed? [yN] "
read YN
[ "$YN" = "y" ] || exit 1

# parameters

hgrepo="http://hg.mozilla.org/users/dmitchell_mozilla.com/puppet"

# check that puppet is installed

if ! puppet --version >/dev/null; then
    echo "Puppet does not appear to be installed."
    exit 1
fi

# clean the system up a bit

# save some space
yum clean all || exit 1

# clean history
rm -f /root/.bash_history || exit 1
cat > /var/log/messages || exit 1
cat > /var/log/wtmp || exit 1

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

hg clone "$hgrepo" /tmp/puppet || exit 1
# TODO...

# finish cleanup

rm -rf /tmp/puppet
#rm -f "$0" # remove this script

echo "Ready to image - halting system"
sleep 2
/sbin/halt
