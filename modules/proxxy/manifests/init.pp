# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
class proxxy {
    include proxxy::settings
    include nginx

    file {
        $proxxy::settings::cache_dir:
            ensure => directory,
            owner  => 'www-data',
            group  => 'root',
            mode   => '0700',
            before => Service['nginx'];

        $proxxy::settings::nginx_conf:
            content => template('proxxy/nginx.conf.erb'),
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            notify  => Service['nginx'],
            require => Class['packages::nginx'];

        $proxxy::settings::nginx_vhosts_conf:
            content   => template('proxxy/nginx-vhosts.conf.erb'),
            owner     => 'root',
            group     => 'root',
            mode      => '0600',
            show_diff => false, # may contain HTTP basic auth credentials
            notify    => Service['nginx'],
            require   => Class['packages::nginx'];
    }
}
