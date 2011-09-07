class yum-repo::updates {
    include yum-repo::dir

    $repo_name = 'updates'
    $repo_url = "http://puppet/yum/mirrors/centos/6.0/latest/updates/$hardwaremodel"

    file {
        "/etc/yum.repos.d/base.repo":
            content => template("yum-repo/repo.erb");
    }
}

