# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

add_phase puppetize
puppetize() {
    local fqdn=$(facter fqdn)
    local ip=$(facter ipaddress)

    if  test -f /var/lib/puppet/ssl/private_keys/${fqdn}.pem && \
        test -f /var/lib/puppet/ssl/certs/${fqdn}.pem && \
        test -f /var/lib/puppet/ssl/certs/ca.pem; then
        return
    fi

    # do the equivalent of puppetize.sh, but without going through the CGI
    mkdir -p /var/lib/puppet/ssl/private_keys
    mkdir -p /var/lib/puppet/ssl/certs
    rm -f /var/lib/puppet/ssl/private_keys/${fqdn}.pem
    rm -f /var/lib/puppet/ssl/certs/${fqdn}.pem
    rm -f /var/lib/puppet/ssl/certs/ca.pem

    /var/lib/puppetmaster/ssl/scripts/deployment_getcert.sh "${fqdn}" "${ip}" > /tmp/certs
    ( cd /var/lib/puppet/ssl && source /tmp/certs )
}

add_phase puppet_agent
puppet_agent() {
    local fqdn=$(facter fqdn)
    local REBOOT_FLAG_FILE="/REBOOT_AFTER_PUPPET"

    rm -f "${REBOOT_FLAG_FILE}"
    puppet agent --detailed-exitcodes --test --server="${fqdn}"
    case $? in
        1|4|6) return 1;;
    esac
    if [ -f "${REBOOT_FLAG_FILE}" ]; then
        echo "NOTE: puppet wants you to reboot"
        return 1
    fi
}
