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

    upstream_rsync_source=`get_local_config puppetmaster_upstream_rsync_source`
    upstream_rsync_args=`get_local_config puppetmaster_upstream_rsync_args`

    if [ -z "${upstream_rsync_source}" ]; then
        if ! [ -d "/data/repos/yum/mirrors" ]; then
            echo "No upstream rsync source for /data is configured (puppetmaster_upstream_rsync_source),"
            echo "which means that you must put /data on this system yourself -- at least /data/repos/yum/mirrors."
            return 1
        fi
    else
        echo "synchronizing /data from ${upstream_rsync_source}; this could take a while.."
        rsync -v --no-p --size-only -a ${upstream_rsync_args} "${upstream_rsync_source}" /data/
    fi
}

add_phase install_puppet
install_puppet() {
    /bin/rpm -q puppet >/dev/null 2>&1 || /usr/bin/yum -y -q install puppet
}
