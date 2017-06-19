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
                    home       => $homedir,
                    password   => '*', # unlock the account without setting a password
                    comment    => 'synchronizes data beteween puppet masters';
            }
        }
        default: {
            fai("No support for ${::operatingsystem}")
        }
    }

    # set up the puppetsync homedir and its SSH config
    file {
        $homedir:
            ensure  => directory,
            owner   => puppetsync,
            group   => puppetsync,
            mode    => '0700',
            purge   => true,
            recurse => true,
            force   => true,
            require => User['puppetsync'];
        "${homedir}/.ssh":
            ensure => directory,
            owner  => puppetsync,
            group  => puppetsync,
            mode   => '0700';
        "${homedir}/.ssh/known_hosts":
            ensure => absent;
        "${homedir}/.ssh/config":
            content => template("${module_name}/puppetsync_ssh_config.erb"),
            owner   => puppetsync,
            group   => puppetsync,
            mode    => '0600';
    }

    # the keys are kept outside of ~puppetsync where the master can access them
    $privkey = '/var/lib/puppet/.puppetsync_rsa'
    $pubkey  = '/var/lib/puppet/.puppetsync_rsa.pub'

    if ($::puppetmaster::settings::is_distinguished) {
        exec {
            'create-puppetsync-private-key':
                command   => "/usr/bin/ssh-keygen -f ${privkey} -N ''",
                logoutput => true,
                creates   => $privkey;
        }

        $puppetsync_pubkey = file($pubkey)

        file {
            "${homedir}/.ssh/authorized_keys":
                content => template("${module_name}/puppetsync_authorized_keys.erb"),
                owner   => puppetsync,
                group   => puppetsync,
                mode    => '0600';
        }
        # (authorized_keys will be removed by recurse => true on non-distinguished masters)
    } else {
        # copy the private key from the current master
        file {
            # the copy of the key that's actually used
            "${homedir}/.ssh/puppetsync_rsa":
                owner     => puppetsync,
                group     => puppetsync,
                mode      => '0600',
                content   => file($privkey),
                show_diff => false;
        }
    }

    file {
        # and everyone gets copies to share among the masters
        $privkey:
            owner     => puppet,
            group     => puppet,
            mode      => '0600',
            content   => file($privkey),
            show_diff => false;
        $pubkey:
            owner   => puppet,
            group   => puppet,
            mode    => '0600',
            content => file($pubkey);
    }
}
