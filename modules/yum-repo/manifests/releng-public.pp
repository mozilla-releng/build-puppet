class yum-repo::releng-public {
    include yum-repo::dir

    $repo_name = 'releng-public'
    $repo_url = "http://puppet/yum/releng/public/noarch"

    file {
        "/etc/yum.repos.d/base.repo":
            content => template("yum-repo/repo.erb");
    }
}


