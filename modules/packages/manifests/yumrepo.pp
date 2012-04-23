define packages::yumrepo ($repo_name = $title, $url_path, $gpg_key='', $gpg_key_pkg='') {
    include config
    include yum_config

    $mirror_file = "/etc/yum.repos.d/$repo_name.mirrors"

    # for the template
    $ipaddress = $::ipaddress
    $repo_servers = $config::repo_servers
    $yum_server = $config::yum_server

    # For now (puppet 2.7.1 as of this writing)
    # we have to use the file resource here, the
    # yumrepo resource is unable to purge. And even if
    # we set the yum.repos.d directory to purge the
    # yumrepo resource does not mark the created files
    # as managed, so we would end up continuously deleting
    # and creating files.
    file {
        "/etc/yum.repos.d/$repo_name.repo":
            content => template("packages/yumrepo.erb");

        $mirror_file:
            content => template("packages/mirrorlist.erb");
    }

    if ($gpg_key) {
        file {
            "/etc/pki/${repo_name}-pubkey.txt":
                source => $gpg_key,
                notify => Exec["install-${repo_name}-repo-pubkey"];
        }
        exec {
            "install-${repo_name}-repo-pubkey":
                command => "/bin/rpm --import /etc/pki/${repo_name}-pubkey.txt",
                logoutput => on_failure,
                unless => "/bin/rpm -q $gpg_key_pkg";
        }
    }
}
