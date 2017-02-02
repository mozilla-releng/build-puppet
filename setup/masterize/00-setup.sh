# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

add_phase check_os
check_os() {
    if ! grep -q 'CentOS' /etc/issue; then
        echo "masterize.sh only works on CentOS"
        return 1
    fi
}

add_phase setup_hostname
setup_hostname() {
    local myhostname=`hostname -s`
    local myfqdn=`hostname`
    if [ "$myhostname" == "$myfqdn" ]; then
        echo "This host doesn't have a fqdn set. That will break ssl stuff. Please run \`hostname <fqdn>\` and run this script again."
        return 1
    fi

    # fix the hostname in /etc/sysconfig/network
    if ! grep -q $myfqdn /etc/sysconfig/network; then
        sed -i "s/^HOSTNAME=.*/HOSTNAME=$myfqdn/" /etc/sysconfig/network
    fi
}

add_phase setup_clock
setup_clock() {
    : ${ntp_server:="pool.ntp.org"}
    /sbin/service ntpd stop || true
    if ! /usr/sbin/ntpdate ${ntp_server}; then
        echo "Could not synchronize time; run masterize with"
        echo "  ntp_server=<your ntp server> ./setup/masterize.sh"
        echo "to override the NTP server"
        return 1
    fi
}

add_phase setup_yum_repos
setup_yum_repos() {
    [ -f /etc/yum.repos.d/bootstrap.repo ] && return

    rm -rf /etc/yum.repos.d/*
    cat <<'EOF' >/etc/yum.repos.d/bootstrap.repo
[centos-os]
name=centos - os - $basearch
baseurl=http://puppet/data/repos/yum/mirrors/centos/6/latest/os/$basearch
enabled=1
gpgcheck=0

[centos-updates]
name=centos - updates - $basearch
baseurl=http://puppet/data/repos/yum/mirrors/centos/6/latest/updates/$basearch
enabled=1
gpgcheck=0

[releng]
name=releng
baseurl=http://puppet/data/repos/yum/releng/public/CentOS/6/$basearch
enabled=1
gpgcheck=0

[releng-noarch]
name=releng-noarch
baseurl=http://puppet/data/repos/yum/releng/public/CentOS/6/noarch
enabled=1
gpgcheck=0

[puppet]
name=puppet
baseurl=http://puppet/data/repos/yum/mirrors/puppetlabs/el/6/products/$basearch
enabled=1
gpgcheck=0

[puppet-deps]
name=puppet
baseurl=http://puppet/data/repos/yum/mirrors/puppetlabs/el/6/dependencies/$basearch
enabled=1
gpgcheck=0
EOF
    /usr/bin/yum clean all
}

SSH_PRIVATE_KEY="/var/lib/puppet/.puppetsync_rsa"
SSH_PUBLIC_KEY="${SSH_PRIVATE_KEY}.pub"
add_phase setup_ssh_keys
setup_ssh_keys() {
    [ -f "${SSH_PRIVATE_KEY}" ] && return
    mkdir -p /var/lib/puppet
    ssh-keygen -f "${SSH_PRIVATE_KEY}" -N ''
    # puppet will eventually set ownership (puppet:puppet) and permissions on this
    # but the puppet user doesn't exist yet, so we just set it to a+r temporarily
    chmod a+r "${SSH_PRIVATE_KEY}" "${SSH_PUBLIC_KEY}"
}

add_phase install_eyaml
install_eyaml() {
    if ! /bin/rpm -q rubygem-hiera-eyaml >/dev/null 2>&1; then
        /usr/bin/yum -y -q install rubygem-hiera-eyaml
    fi
}

add_phase setup_hiera_yaml
setup_hiera_yaml() {
    # put in enough of a hiera.yaml to bootstrap things - puppet will manage this
    # later.
    cat <<'EOF' > /etc/hiera.yaml
---
:backends:
    - eyaml

:hierarchy:
    - secrets

:eyaml:
    :datadir: '/etc/hiera'
    :pkcs7_private_key:  /etc/hiera/keys/private_key.pem
    :pkcs7_public_key:  /etc/hiera/keys/public_key.pem
EOF
    ln -s /etc/puppet/hiera.yaml /etc/hiera.yaml
}


add_phase setup_eyaml_keys
setup_eyaml_keys() {
    local keys_dir="/etc/hiera/keys"
    [ -f "${keys_dir}/private_key.pem" ] && [ -f "${keys_dir}/public_key.pem" ] && return
    mkdir -p "${keys_dir}"
    eyaml -c
}

add_phase setup_secrets
setup_secrets() {
    local secrets_file="/etc/hiera/secrets.eyaml"
    [ -f "${secrets_file}" ] && return
    echo "'${secrets_file}' does not exist.  Create it now with at least 'root_pw_hash' and 'puppetmaster_deploy_password' set"
    cat <<'EOF'
---
# note: these do not need to be eyaml-encrypted yet.  You should do that soon, though.
root_pw_hash: <put yours here, passwd-encrypted>
puppetmaster_deploy_htpasswd: <put yours here, htpasswd-encrypted>
# you can be more limited here if you'd like, but this will do for now:
network_regexps: 0.0.0.0/0
EOF
    return 1
}

add_phase setup_config
setup_config() {
    local config_link="$PWD/manifests/config.pp"
    local nodes_link="$PWD/manifests/nodes.pp"
    ok=true
    if [ -f "${config_link}" ]; then
        echo "config:" `readlink "${config_link}"`
    else
        ok=false
    fi
    if [ -f "${nodes_link}" ]; then
        echo "nodes:" `readlink "${nodes_link}"`
    else
        ok=false
    fi
    if ! $ok; then
        echo "One or both of '${config_link}' or '${nodes_link}' do not exist.  Link them to the"
        echo "appropriate config and nodes for this org, e.g."
        echo " (cd $PWD/manifests; ln -s myorg-config.pp config.pp)"
        echo " (cd $PWD/manifests; ln -s myorg-nodes nodes.pp)"
        return 1
    fi
}
