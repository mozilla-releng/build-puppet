class yum-repo::base {
    include yum-repo::dir

    $repo_name = 'base'
    $repo_url = "http://puppet/yum/mirrors/centos/$operatingsystemrelease/os/$hardwaremodel"

    file {
        "/etc/yum.repos.d/base.repo":
            content => template("yum-repo/repo.erb");
    }
}
