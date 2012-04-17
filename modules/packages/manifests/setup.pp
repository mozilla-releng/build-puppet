class packages::setup {
    include config

    file {
        # this will ensure that any "stray" yum repos will be deleted
        "/etc/yum.repos.d":
            ensure => directory,
            recurse => true,
            purge => true;
    }

    packages::yumrepo {
        "epel":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/epel/6/latest/$hardwaremodel",
            gpg_key => "puppet:///modules/packages/0608B895.txt",
            gpg_key_pkg => 'gpg-pubkey-0608b895-4bd22942';
        "base":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/centos/6/latest/os/$hardwaremodel/Packages",
            gpg_key => "puppet:///modules/packages/RPM-GPG-KEY-CentOS-6",
            gpg_key_pkg => 'gpg-pubkey-c105b9de-4e0fd3a3';
        "updates":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/centos/6/latest/updates/$hardwaremodel",
            gpg_key => "puppet:///modules/packages/A82BA4B7.txt",
            gpg_key_pkg => 'gpg-pubkey-a82ba4b7-4e2df47d';
        "mozilla-centos6-x86_64":
            baseurl => "http://$config::yum_server/repos/yum/mozilla/CentOS/6/$hardwaremodel";
        "releng-public":
            baseurl => "http://$config::yum_server/repos/yum/releng/public/noarch";
        "puppetlabs":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/puppetlabs/el/6/products/$hardwaremodel";
    }

}
