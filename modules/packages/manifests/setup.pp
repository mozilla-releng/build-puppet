class packages::setup {
    include config

    $majorver = regsubst($operatingsystemrelease, '^(\d+)\.?.*', '\1')

    file {
        # this will ensure that any "stray" yum repos will be deleted
        "/etc/yum.repos.d":
            ensure => directory,
            recurse => true,
            purge => true;
    }

    packages::yumrepo {
        "epel":
            url_path => "repos/yum/mirrors/epel/6/latest/$hardwaremodel",
            gpg_key => "puppet:///modules/packages/0608B895.txt",
            gpg_key_pkg => 'gpg-pubkey-0608b895-4bd22942';
        "base":
            url_path => "repos/yum/mirrors/centos/6/latest/os/$hardwaremodel",
            gpg_key => "puppet:///modules/packages/RPM-GPG-KEY-CentOS-6",
            gpg_key_pkg => 'gpg-pubkey-c105b9de-4e0fd3a3';
        "updates":
            url_path => "repos/yum/mirrors/centos/6/latest/updates/$hardwaremodel",
            gpg_key => "puppet:///modules/packages/A82BA4B7.txt",
            gpg_key_pkg => 'gpg-pubkey-a82ba4b7-4e2df47d';
        "puppetlabs":
            url_path => "repos/yum/mirrors/puppetlabs/el/6/products/$hardwaremodel";
        "releng-public-${operatingsystem}${majorver}-${hardwaremodel}":
            url_path => "repos/yum/releng/public/$operatingsystem/$majorver/$hardwaremodel";
        "releng-public-${operatingsystem}${majorver}-noarch":
            url_path => "repos/yum/releng/public/$operatingsystem/$majorver/noarch";
    }

    # to flush the metadata cache, increase this value by one (or
    # anything, really, just change it).
    $repoflag = 2
    file {
        "/etc/.repo-flag":
            content => "# see \$repoflag in modules/packages/manifests/setup.pp\n$repoflag\n",
            notify => Exec['yum-clean-expire-cache'];
    }
    exec {
        yum-clean-expire-cache:
            # this will expire all yum metadata caches
            command => "/usr/bin/yum clean expire-cache",
            refreshonly => true;
    }
}
