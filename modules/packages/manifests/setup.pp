# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::setup {
    include config

    case $::operatingsystem {
        CentOS : {
            $majorver = regsubst($::operatingsystemrelease, '^(\d+)\.?.*', '\1')
            file {
            # this will ensure that any "stray" yum repos will be deleted
                '/etc/yum.repos.d':
                    ensure  => directory,
                    recurse => true,
                    purge   => true;
            }

            $releasedir = $::operatingsystemrelease ? {
                '6.2'   => '6/latest',
                default => $::operatingsystemrelease
            }
            # repos that are available everywhere
            packages::yumrepo {
                'epel':
                    url_path    => "repos/yum/mirrors/epel/6/latest/${::architecture}",
                    gpg_key     => 'puppet:///modules/packages/0608B895.txt',
                    gpg_key_pkg => 'gpg-pubkey-0608b895-4bd22942';

                'base':
                    url_path    => "repos/yum/mirrors/centos/${releasedir}/os/${::architecture}",
                    gpg_key     => 'puppet:///modules/packages/RPM-GPG-KEY-CentOS-6',
                    gpg_key_pkg => 'gpg-pubkey-c105b9de-4e0fd3a3';

                'updates' :
                    url_path    => "repos/yum/mirrors/centos/${releasedir}/updates/${::architecture}",
                    gpg_key     => 'puppet:///modules/packages/A82BA4B7.txt',
                    gpg_key_pkg => 'gpg-pubkey-a82ba4b7-4e2df47d';

                'puppetlabs':
                    url_path => "repos/yum/mirrors/puppetlabs/el/${majorver}/products/${::architecture}";

                'puppetlabs-deps':
                    url_path => "repos/yum/mirrors/puppetlabs/el/${majorver}/dependencies/${::architecture}";

                "releng-public-${::operatingsystem}${majorver}-${::architecture}":
                    url_path => "repos/yum/releng/public/${::operatingsystem}/${majorver}/${::architecture}" ;

                "releng-public-${::operatingsystem}${majorver}-noarch":
                    url_path => "repos/yum/releng/public/${::operatingsystem}/${majorver}/noarch" ;
            }

            # repos that are only installed where required
            @packages::yumrepo {
                'nodesource':
                    url_path => "repos/yum/mirrors/nodesource/el/${majorver}/${::architecture}";

                'devtools-2':
                    url_path => "repos/yum/mirrors/devtools-2/${majorver}/${::architecture}/RPMS";

                'taskcluster':
                    url_path => "repos/yum/custom/taskcluster/${::architecture}";

                'passenger':
                    url_path => "repos/yum/mirrors/passenger/rhel/${majorver}/latest/${::architecture}";

                'hp-proliantsupportpack':
                    url_path => "repos/yum/mirrors/hp/proliantsupportpack/CentOS/${majorver}/${::architecture}/current";

                'mig-agent':
                    url_path => "repos/yum/custom/mig-agent/${::architecture}";

                'git-remote-hg':
                    url_path => "repos/yum/custom/git-remote-hg/${::architecture}";

                'openssl':
                    url_path => "repos/yum/custom/openssl/${::architecture}";

                'bash':
                    url_path => "repos/yum/custom/bash/${::architecture}";

                'osslsigncode':
                    url_path => "repos/yum/custom/osslsigncode/${::architecture}";

                'auditd':
                    url_path => "repos/yum/custom/auditd/${::architecture}";

                'openipmi':
                    url_path => "repos/yum/custom/openipmi/${::architecture}";

                'mock_mozilla':
                    url_path => "repos/yum/custom/mock_mozilla/${::architecture}";

                'debian': # misc debian utilities
                    url_path => "repos/yum/custom/debian/${::architecture}";

                'kernel':
                    url_path => "repos/yum/custom/kernel/${::architecture}";

                'glibc':
                    url_path => "repos/yum/custom/glibc/${::architecture}";

                'rsyslog':
                    url_path => "repos/yum/custom/rsyslog/${::architecture}";

                'supervisor':
                    url_path => "repos/yum/custom/supervisor/${::architecture}";

                # a licensed copy of bacula enterprise, so not publicly available
                'bacula-enterprise':
                    url_path => "repos/private/yum/mirrors/bacula-enterprise/${majorver}-${::architecture}";

                'collectd':
                    url_path => "repos/yum/custom/collectd/${::architecture}";

                'git':
                    url_path => "repos/yum/custom/git/${::architecture}";

                'mozilla-mercurial':
                    url_path => "repos/yum/custom/mozilla-mercurial/${::architecture}";

                'procmail':
                    url_path => "repos/yum/custom/procmail/${::architecture}";

                'python3':
                    url_path => "repos/yum/custom/mozilla-python36/${::architecture}";

                'python27-12':
                    url_path => "repos/yum/custom/mozilla-python2712/${::architecture}";

                'python27-14':
                    url_path => "repos/yum/custom/mozilla-python2714/${::architecture}";

                'python27-15':
                    url_path => "repos/yum/custom/mozilla-python2715/${::architecture}";

                'squashfs-tools':
                    url_path => "repos/yum/custom/mozilla-squashfs-tools/${::architecture}";

                'clamav':
                    url_path => "repos/yum/custom/clamav/${::architecture}";

                'security_update_1319455':
                    url_path => "repos/yum/custom/security_update_1319455/${::architecture}";

                'security_update_1433165':
                    url_path => "repos/yum/custom/security_update_1433165/${::architecture}";

                'signmar':
                    url_path => "repos/yum/custom/signmar/${::architecture}";

                'nss':
                    url_path => "repos/yum/custom/nss/${::architecture}";

                'bind-utils':
                    url_path => "repos/yum/custom/bind-utils/${::architecture}";

                'mailx':
                    url_path => "repos/yum/custom/mailx/${::architecture}";

                'ntp':
                    url_path => "repos/yum/custom/ntp/${::architecture}";

                'snmp':
                    url_path => "repos/yum/custom/snmp/${::architecture}";

                'mysql':
                    url_path => "repos/yum/custom/mysql/${::architecture}";

                'jdk17':
                    url_path => "repos/yum/custom/jdk17/${::architecture}";

                'subversion':
                    url_path => "repos/yum/custom/subversion/${::architecture}";

                'httpd':
                    url_path => "repos/yum/custom/httpd/${::architecture}";

                'openssh':
                    url_path => "repos/yum/custom/openssh/${::architecture}";

                'duo_unix':
                    url_path => "repos/yum/custom/duo_unix/${::architecture}";

                'lego':
                    url_path => "repos/yum/custom/lego/${::architecture}";

                'dhcp':
                    url_path => "repos/yum/custom/dhcp/${::architecture}";
            }

            # to flush the metadata cache, increase this value by one (or
            # anything, really, just change it).
            $repoflag = 94
            file {
                '/etc/.repo-flag':
                    content =>
                    "# see \$repoflag in modules/packages/manifests/setup.pp\n${repoflag}\n",
                    notify  => Exec['yum-clean-expire-cache'];
            }
            exec {
                'yum-clean-expire-cache':
                    # this will expire all yum metadata caches
                    command     => '/usr/bin/yum clean expire-cache',
                    refreshonly => true;
                'yum-clean-all':
                    # this is necessary when mirror lists change
                    command     => '/usr/bin/yum clean all',
                    refreshonly => true;
            }
        }
        Ubuntu: {
            # apt-get doesn't expire the package index. Run "apt-get update" on
            # daily basis or when /etc/.repo-flag is bumped
            schedule {
                'daily':
                    period => daily;
            }
            exec {
                'apt-get-update-daily':
                    command  => '/usr/bin/apt-get update',
                    schedule => 'daily';
                'apt-get-update':
                    command     => '/usr/bin/apt-get update',
                    refreshonly => true;
            }
            # to flush the package index, increase this value by one (or
            # anything, really, just change it).
            $repoflag = 42
            file {
                '/etc/.repo-flag':
                    content =>
                    "# see \$repoflag in modules/packages/manifests/setup.pp\n${repoflag}\n",
                    notify  => Exec['apt-get-update'];
                # Make sure that the main file is empty
                '/etc/apt/sources.list':
                    owner   => 0,
                    group   => 0,
                    mode    => '0644',
                    content => "# Managed by puppet\n",
                    notify  => Exec['apt-get-update'];
                # Purge not managed files under this directory
                '/etc/apt/sources.list.d':
                    ensure  => directory,
                    purge   => true,
                    recurse => true,
                    force   => true;
                # Disable periodic apt operations from cron
                '/etc/apt/apt.conf.d/10periodic':
                    content => "APT::Periodic::Enable \"0\";\n";
                # Copy puppetmaster CA cert to a world readable location
                '/etc/ssl/certs/ca.pem':
                    ensure => present,
                    owner  => 0,
                    group  => 0,
                    mode   => '0644',
                    source => 'file:/var/lib/puppet/ssl/certs/ca.pem';
                # Allow not signed packages until we sign them
                '/etc/apt/apt.conf.d/99mozilla':
                    source => 'puppet:///modules/packages/apt.conf.mozilla';
            }
            case $::operatingsystemrelease {
                '16.04' : {
                    packages::aptrepo {
                        'xenial':
                            url_path     => 'repos/apt/Ubuntu-16.04',
                            distribution => 'xenial',
                            components   => ['main', 'restricted', 'universe'];
                        'xenial-security':
                            url_path     => 'repos/apt/Ubuntu-16.04',
                            distribution => 'xenial-security',
                            components   => ['main', 'restricted', 'universe'];
                        'xenial-updates':
                            url_path     => 'repos/apt/Ubuntu-16.04',
                            distribution => 'xenial-updates',
                            components   => ['main', 'restricted', 'universe'];
                    }
                    # Bug 1360050 - Remove appstreams from apt on Ubuntu 16.04
                    file {
                        '/etc/apt/apt.conf.d/50appstream':
                            ensure => absent;
                    }
                }
                '14.04', '12.04' : {
                    packages::aptrepo {
                        $::lsbdistcodename:
                            url_path     => 'repos/apt/ubuntu',
                            distribution => $::lsbdistcodename,
                            components   => ['main', 'restricted', 'universe'];
                        "${::lsbdistcodename}-security":
                            url_path     => 'repos/apt/ubuntu',
                            distribution => "${::lsbdistcodename}-security",
                            components   => ['main', 'restricted', 'universe'];
                        'releng':
                            url_path     => 'repos/apt/releng',
                            distribution => $::lsbdistcodename,
                            components   => ['main'];
                        'releng-updates':
                            url_path     => 'repos/apt/releng-updates',
                            distribution => "${::lsbdistcodename}-updates",
                            components   => ['all'];
                        'puppetlabs':
                            url_path     => 'repos/apt/puppetlabs',
                            distribution => $::lsbdistcodename,
                            components   => ['dependencies', 'main'];
                    }
                }
                default: {
                fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }

            @packages::aptrepo {
                'graphics-drivers':
                    url_path     => 'repos/apt/graphics-drivers',
                    distribution => $::lsbdistcodename,
                    components   => ['main'];
                'nginx-development':
                    url_path     => 'repos/apt/nginx-development',
                    distribution => $::lsbdistcodename,
                    components   => ['main'];
                'mig-agent':
                    url_path     => 'repos/apt/custom/mig-agent',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'openssl':
                    url_path     => 'repos/apt/custom/openssl',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'bash':
                    url_path     => 'repos/apt/custom/bash',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'eglibc':
                    url_path     => 'repos/apt/custom/eglibc',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'mozilla-mercurial':
                    url_path     => 'repos/apt/custom/mozilla-mercurial',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'kernel':
                    url_path     => 'repos/apt/custom/kernel',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'collectd':
                    url_path     => 'repos/apt/custom/collectd',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'mesa-lts-saucy':
                    url_path     => 'repos/apt/custom/mesa-lts-saucy',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'git':
                    url_path     => 'repos/apt/custom/git',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'libxcb':
                    url_path     => 'repos/apt/custom/libxcb',
                    distribution => $::lsbdistcodename,
                    options      => ['trusted=yes'],
                    components   => ['all'];
                'docker_ce':
                    url_path     => 'repos/apt/apt-mirrors/download.docker.com/linux/ubuntu',
                    distribution => $::lsbdistcodename,
                    components   => ['stable'],
                    options      => ['arch=amd64'],
                    gpg_id       => '0EBFCD88',
                    gpg_key      => 'puppet:///modules/packages/0EBFCD88.txt';
            }
        }
        Darwin: {
            #nothing to setup on Darwin
        }
    }
}
