class yum-repo::epel {
    include yum-repo::dir

    $repo_name = 'epel'
    $repo_url = "http://puppet/yum/mirrors/epel/6/latest/$hardwaremodel"

    file {
        "/etc/yum.repos.d/epel.repo":
            content => template("yum-repo/repo.erb");
    }
}
