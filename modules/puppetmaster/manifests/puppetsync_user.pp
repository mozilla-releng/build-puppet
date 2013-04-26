# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::puppetsync_user {
    include puppetmaster::settings
    $homedir = $puppetmaster::settings::puppetsync_home

    case $::operatingsystem {
        CentOS, Ubuntu: {
            user {
                'puppetsync':
                    managehome => true,
                    home => $homedir,
                    password => '*', # unlock the account without setting a password
                    comment => "synchronizes data beteween puppet masters";
            }
        }
        default: {
            fai("No support for $::operatingsystem")
        }
    }

    # set up SSH for the user
    # set up the puppetsync homedir and its SSH config
    file {
        "${homedir}":
            owner => puppetsync,
            group => puppetsync,
            mode => "0700",
            purge => true,
            recurse => true,
            force => true,
            require => User['puppetsync'];
        "${homedir}/.ssh":
            owner => puppetsync,
            group => puppetsync,
            mode => "0700",
            ensure => directory;
        "${homedir}/.ssh/known_hosts":
            content => template("${module_name}/puppetsync_known_hosts.erb"),
            owner => puppetsync,
            group => puppetsync,
            mode => "0600";
        "${homedir}/.ssh/config":
            content => "CheckHostIp no\nStrictHostKeyChecking yes\n",
            owner => puppetsync,
            group => puppetsync,
            mode => "0600";
    }

    # check that the private key is present
    $privkey = "${homedir}/.ssh/id_rsa"
    exec {
        'check-puppetsync-private-key':
            command => "/bin/echo 'Copy ${privkey} from the distinguished master and chmod 0600 / chown puppetsync:puppetsync'; false",
            logoutput => true,
            creates => $privkey;
    }

    if ($::puppetmaster::settings::is_distinguished) {
        if ($::config::secrets::puppetsync_pubkey == '') {
            fail("puppetsync public key is not specified in secrets.csv; if the key doesn't exist, use 'ssh-keygen' to create one and put the public portion in secrets.csv")
        }
        file {
            "${homedir}/.ssh/authorized_keys":
                content => template("${module_name}/puppetsync_authorized_keys.erb"),
                owner => puppetsync,
                group => puppetsync,
                mode => "0600";
        }
        # (authorized_keys will be removed by recurse => true on non-distinguished masters)
    }
}
