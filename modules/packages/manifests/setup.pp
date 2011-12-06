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
        "base":
            baseurl => "http://$config::yum_server/yum/mirrors/centos/$operatingsystemrelease/os/$hardwaremodel";
        "epel":
            baseurl => "http://$config::yum_server/yum/mirrors/epel/6/latest/$hardwaremodel";
        "updates":
            baseurl => "http://$config::yum_server/yum/mirrors/centos/6.0/latest/updates/$hardwaremodel";
        "releng-public":
            baseurl => "http://$config::yum_server/yum/releng/public/noarch";
    }

}
