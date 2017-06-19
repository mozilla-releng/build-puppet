# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::httpd {
    include puppetmaster::ssl # for the variables, used in templates

    $deploy_htpasswd = secret('puppetmaster_deploy_htpasswd')
    case $::operatingsystem {
        CentOS: {
            file {
                '/etc/puppet/deploy.htpasswd':
                    content   => "deploy:${deploy_htpasswd}",
                    show_diff => false;
                ['/etc/puppet/rack', '/etc/puppet/rack/public']:
                    ensure  => directory,
                    require => Class['puppet'],
                    owner   => puppet,
                    group   => puppet,
                    notify  => Service['httpd'];
                '/etc/puppet/rack/config.ru':
                    owner  => puppet,
                    group  => puppet,
                    source => 'puppet:///modules/puppetmaster/config.ru',
                    notify => Service['httpd'];
            }

            # make sure the puppetmaster service isn't running, since we're
            # using mod_passenger instead
            service {
                'puppetmaster':
                    ensure  => stopped,
                    require => Class['puppetmaster::install'],
                    enable  => false;
            }

            httpd::config {
                'data.conf':
                    content => template('puppetmaster/data.conf.erb');
                'puppetmaster_passenger.conf':
                    content => template('puppetmaster/puppetmaster_passenger.conf.erb');
            }

            # add a dependency between resources not defined here
            File['/etc/puppet/puppet.conf'] ~> Service['httpd']
            Package['openssl'] ~> Service['httpd']
        }

        default: {
            fail("puppetmaster::httpd support missing for ${::operatingsystem}")
        }
    }
}
