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
            url_path => "repos/yum/mirrors/epel/6/latest/$hardwaremodel";
        "base":
            url_path => "repos/yum/mirrors/centos/6/latest/os/$hardwaremodel";
        "updates":
            url_path => "repos/yum/mirrors/centos/6/latest/updates/$hardwaremodel";
        "mozilla-centos6-x86_64":
            url_path => "repos/yum/mozilla/CentOS/6/$hardwaremodel";
        "releng-public":
            url_path => "repos/yum/releng/public/noarch";
        "puppetlabs":
            url_path => "repos/yum/mirrors/puppetlabs/el/6/products/$hardwaremodel";
    }

}
