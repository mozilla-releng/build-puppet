# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

puppet_apply() {
    (
        # don't import site.pp here, as the node defitions will
        # mess up the requested manifests
        echo "import '$PWD/manifests/extlookup.pp'"
        echo "import '$PWD/manifests/stages.pp'"
        cat
    ) > /tmp/apply.pp

    FACTER_MASTERIZING=true \
    /usr/bin/puppet apply --modulepath $PWD/modules \
        --manifestdir $PWD/manifests \
        --detailed-exitcodes \
        /tmp/apply.pp
    case $? in
        0|2) return 0;;
        1|4|6) return 1;;
    esac
}

add_phase apply_base
apply_base() {
    puppet_apply <<'EOF'
    include toplevel::base
EOF
}

add_phase check_distinguished_master
check_distinguished_master() {
    puppet_apply <<'EOF'
    include toplevel::base
    include ::config
    if ($::config::distinguished_puppetmaster != $::fqdn) {
        fail("this host ($fqdn) is not the configured distinguished master (${::config::distinguished_puppetmaster})")
    }
EOF
}

add_phase apply_puppetmaster_manifests
apply_puppetmaster_manifests() {
    rm -rf "/etc/puppet/production"
    puppet_apply <<'EOF'
    include toplevel::base
    include puppetmaster::manifests
EOF
    # copy secrets and local-config in there
    cp -P "$PWD/manifests/extlookup/local-config.csv" "$PWD/manifests/extlookup/secrets.csv" \
            /etc/puppet/production/manifests/extlookup/
    chown -R root:root /etc/puppet/production/manifests/extlookup/
    chmod 755 /etc/puppet/production/manifests/extlookup/secrets.csv
}

add_phase apply_puppetmaster_ssl
apply_puppetmaster_ssl() {
    # this will fail the first few times until the user adds the required
    # certs, but it gives nice instructions
    puppet_apply <<'EOF'
    include toplevel::base
    include puppetmaster::ssl
EOF
}

add_phase apply_puppetmaster
apply_puppetmaster() {
    # this should properly start up Apache
    echo "NOTE: Servce['nrpe'] may fail here; the failure is harmless and due to a bug in puppet"
    puppet_apply <<'EOF'
    include toplevel::server::puppetmaster
EOF
}

add_phase check_puppetmaster
check_puppetmaster() {
    # check server-side validity with s_client
    for port in 443 8140; do
        echo "Trying https://localhost:$port/; expect verifies to return 1"
        echo $'GET / HTTP/1.0\n' | \
            openssl s_client -connect "127.0.0.1:$port" -verify 2 \
                    -CAfile "/var/lib/puppetmaster/ssl/git/ca-certs/root.crt" \
                > "/tmp/verify.out"
        if ! grep -q "Verify return code: 0 (ok)" "/tmp/verify.out"; then
            cat "${B}/apache/error_log"
            return 1
        fi
    done
}
