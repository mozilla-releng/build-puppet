# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

add_phase install_data
install_data() {
    if ! /bin/rpm -q rsync >/dev/null 2>&1; then
        echo "rsync is not installed, although it's included in the Base group in CentOS"
        echo "please use 'yum' to install it with a full URL, perhaps based on"
        echo "http://puppetagain.pub.build.mozilla.org/data/repos/yum/mirrors/centos/6/latest/os/"
        return 1
    fi

    if ! [ -d "/data/repos/yum/mirrors" ]; then
        echo "You must put /data on this system yourself -- at least /data/repos/yum/mirrors."
        echo "In the absence of a better option for your organization, use this:"
        echo "  rsync -v --no-p --size-only -a rsync://puppetagain.pub.build.mozilla.org/data/ /data/"
        return 1
    fi
}

add_phase install_puppet
install_puppet() {
    /bin/rpm -q puppet >/dev/null 2>&1 || /usr/bin/yum -y -q install puppet
}
