# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::hiera {
    # we use hiera-eyaml to store encrypted secrets inside an otherwise-normal
    # YAML file
    include packages::mozilla::hiera_eyaml

    file {
        "/etc/puppet/hiera.yaml":
            content => template("puppetmaster/hiera.yaml.erb"),
            require => Class['packages::mozilla::hiera_eyaml'], # otherwise httpd won't see it
            notify => Service['httpd'];
        [ "/etc/hiera", "/etc/hiera/keys", "/etc/hiera/environments" ]:
            ensure => directory,
            owner => puppet,
            group => puppet,
            mode => 0700;
    }

    file {
        # this is the old crontask for extlookup-based secrets
        "/etc/cron.d/rsync-extlookup":
            ensure => absent;
    }

    # if we're not the distinguished master, rsync the entire hiera dir from
    # the distingiushed master (minus environments)
    if ($puppetmaster::settings::is_distinguished) {
        file {
            '/etc/cron.d/rsync-secrets':
                ensure => absent
        }
    } else {
        file {
            '/etc/cron.d/rsync-secrets':
                content => template("${module_name}/rsync-secrets.erb");
        }
    }
}
