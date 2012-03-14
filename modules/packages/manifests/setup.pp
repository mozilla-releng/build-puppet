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
            baseurl => "http://$config::yum_server/repos/yum/mirrors/centos/6/latest/os/$hardwaremodel/Packages";
        "updates":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/centos/6/latest/updates/$hardwaremodel";
        #"mozilla-centos6-x86_64":
        #    baseurl => "http://$config::yum_server/repos/yum/mozilla/centos/6/latest/$hardwaremodel";
        "johnford-org-centos6-x86_64":
            baseurl => "http://johnford.org/repos/";
        "releng-public":
            baseurl => "http://$config::yum_server/repos/yum/releng/public/noarch";
        "puppetlabs":
            baseurl => "http://$config::yum_server/repos/yum/mirrors/puppetlabs/el/6/products/$hardwaremodel";
    }

}
