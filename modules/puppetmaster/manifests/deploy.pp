# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::deploy {
    include ::config
    include puppetmaster::settings
    include packages::httpd

    $manager_ips = secret('manager_ips')
    $network_regexps = secret('network_regexps')
    $fqdn_regexps = secret('fqdn_regexps')
    $deployment_getcert_sh = "${puppetmaster::settings::puppetmaster_root}/ssl/scripts/deployment_getcert.sh"

    file {
        $puppetmaster::settings::deploy_dir:
            ensure  => directory,
            recurse => true,
            force   => true;
        "${puppetmaster::settings::deploy_dir}/cgi-bin":
            ensure => directory,
            mode   => '0750',
            owner  => root,
            group  => apache;
        "${puppetmaster::settings::deploy_dir}/cgi-bin/getcert.cgi":
            mode    => '0750',
            owner   => root,
            group   => apache,
            require => Class['packages::httpd'],
            content => template("${module_name}/getcert.cgi.erb");
    }

    # getcert.cgi uses sudo to run deployment_getcert.sh
    sudoers::custom {
        'getcert':
            user    => 'apache',
            runas   => 'root',
            command => $deployment_getcert_sh;
    }
}
