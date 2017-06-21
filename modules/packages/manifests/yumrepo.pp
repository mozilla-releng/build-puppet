# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define packages::yumrepo ($url_path, $repo_name = $title, $gpg_key='', $gpg_key_pkg='') {
    include config
    include yum_config

    $mirror_file = "/etc/yum.repos.d/${repo_name}.mirrors"

    # for the template
    $ipaddress    = $::ipaddress
    $data_server  = $config::data_server
    $data_servers = $config::data_servers

    # This class uses numeric user/group IDs since this resource is in the
    # 'packagesetup' state, which comes before the 'main' stage where
    # User['root'] occurs..

    # For now (puppet 2.7.1 as of this writing)
    # we have to use the file resource here, the
    # yumrepo resource is unable to purge. And even if
    # we set the yum.repos.d directory to purge the
    # yumrepo resource does not mark the created files
    # as managed, so we would end up continuously deleting
    # and creating files.
    file {
        "/etc/yum.repos.d/${repo_name}.repo":
            owner   => 0,
            group   => 0,
            mode    => '0644',
            content => template('packages/yumrepo.erb'),
            notify  => Exec['yum-clean-all'];

        $mirror_file:
            owner   => 0,
            group   => 0,
            mode    => '0644',
            content => template('packages/mirrorlist.erb'),
            notify  => Exec['yum-clean-all'];
    }

    if ($gpg_key) {
        file {
            "/etc/pki/${repo_name}-pubkey.txt":
                source    => $gpg_key,
                owner     => 0,
                group     => 0,
                mode      => '0644',
                notify    => Exec["install-${repo_name}-repo-pubkey"],
                show_diff => false;
        }
        exec {
            "install-${repo_name}-repo-pubkey":
                command   => "/bin/rpm --import /etc/pki/${repo_name}-pubkey.txt",
                logoutput => on_failure,
                unless    => "/bin/rpm -q ${gpg_key_pkg}";
        }
    }
}
