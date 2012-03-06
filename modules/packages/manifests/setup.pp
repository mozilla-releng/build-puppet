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
            baseurl => "http://$config::yum_server/repos/yum/mirrors/epel/6/latest/$hardwaremodel";
        "base":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/centos/6/latest/os/$hardwaremodel";
        "updates":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/centos/6/latest/updates/$hardwaremodel";
        "releng-public":
            baseurl => "http://$config::yum_server/repos/yum/releng/public/noarch";
    }

}
