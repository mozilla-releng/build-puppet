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
                "/etc/yum.repos.d":
                    ensure => directory,
                    recurse => true,
                    purge => true;
            }

            # repos that are available everywhere
            packages::yumrepo {
                "epel":
                    url_path =>
                    "repos/yum/mirrors/epel/6/latest/$architecture",
                    gpg_key => "puppet:///modules/packages/0608B895.txt",
                    gpg_key_pkg => 'gpg-pubkey-0608b895-4bd22942';

                "base":
                    url_path =>
                    "repos/yum/mirrors/centos/6/latest/os/$architecture",
                    gpg_key => "puppet:///modules/packages/RPM-GPG-KEY-CentOS-6",
                    gpg_key_pkg => 'gpg-pubkey-c105b9de-4e0fd3a3';

                "updates" :
                    url_path => "repos/yum/mirrors/centos/6/latest/updates/$architecture",
                    gpg_key => "puppet:///modules/packages/A82BA4B7.txt",
                    gpg_key_pkg => 'gpg-pubkey-a82ba4b7-4e2df47d';

                "puppetlabs":
                    url_path => "repos/yum/mirrors/puppetlabs/el/6/products/$architecture";

                "puppetlabs-deps":
                    url_path => "repos/yum/mirrors/puppetlabs/el/6/dependencies/$architecture";

                "releng-public-${operatingsystem}${majorver}-${architecture}":
                    url_path => "repos/yum/releng/public/$operatingsystem/$majorver/$architecture" ;

                "releng-public-${operatingsystem}${majorver}-noarch":
                    url_path => "repos/yum/releng/public/$operatingsystem/$majorver/noarch" ;
            }

            # repos that are only installed where required
            @packages::yumrepo {
                "passenger":
                    url_path => "repos/yum/mirrors/passenger/rhel/$majorver/latest/$architecture";

                "hp-proliantsupportpack":
                    url_path => "repos/yum/mirrors/hp/proliantsupportpack/CentOS/$majorver/$architecture/current";
            }

            # to flush the metadata cache, increase this value by one (or
            # anything, really, just change it).
            $repoflag = 5
            file {
                "/etc/.repo-flag":
                    content =>
                    "# see \$repoflag in modules/packages/manifests/setup.pp\n$repoflag\n",
                    notify => Exec['yum-clean-expire-cache'];
            }
            exec {
                yum-clean-expire-cache:
                    # this will expire all yum metadata caches
                    command => "/usr/bin/yum clean expire-cache",
                    refreshonly => true;
                yum-clean-all:
                    # this is necessary when mirror lists change
                    command => "/usr/bin/yum clean all",
                    refreshonly => true;
            }
        }
        Ubuntu: {
            # apt-get doesn't expire the package index. Run "apt-get update" on
            # daily basis or when /etc/.repo-flag is bumped
            schedule {
                "daily":
                    period => daily;
            }
            exec {
                "apt-get-update-daily":
                    command     => "/usr/bin/apt-get update",
                    schedule    => "daily";
                "apt-get-update":
                    command     => "/usr/bin/apt-get update",
                    refreshonly => true;
            }
            # to flush the package index, increase this value by one (or
            # anything, really, just change it).
            $repoflag = 3
            file {
                "/etc/.repo-flag":
                    content =>
                    "# see \$repoflag in modules/packages/manifests/setup.pp\n$repoflag\n",
                    notify => Exec['apt-get-update'];
                # Make sure that the main file is empty
                "/etc/apt/sources.list":
                    owner => 0,
                    group => 0,
                    mode => 0644,
                    content => "# Managed by puppet\n",
                    notify => Exec['apt-get-update'];
                # Purge not managed files under this directory
                "/etc/apt/sources.list.d":
                    ensure  => directory,
                    purge   => true,
                    recurse => true,
                    force   => true;
                # Allow not signed packages until we sign them
                "/etc/apt/apt.conf.d/99mozilla":
                    source => "puppet:///modules/packages/apt.conf.mozilla";
            }
            packages::aptrepo {
                "precise":
                    url_path     => "repos/apt/ubuntu",
                    distribution => "precise",
                    components   => ["main", "restricted", "universe"];
                "precise-security":
                    url_path     => "repos/apt/ubuntu",
                    distribution => "precise-security",
                    components   => ["main", "restricted", "universe"];
                "releng":
                    url_path     => "repos/apt/releng",
                    distribution => "precise",
                    components   => ["main"];
                "releng-updates":
                    url_path     => "repos/apt/releng-updates",
                    distribution => "precise-updates",
                    components   => ["all"];
            }
            @packages::aptrepo {
                "xorg-edgers":
                    url_path     => "repos/apt/xorg-edgers",
                    distribution => "precise",
                    components   => ["main"];
            }
        }
        Darwin: {
            #nothing to setup on Darwin
        }
    }
}
