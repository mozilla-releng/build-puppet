# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define packages::aptrepo ($url_path, $distribution, $components, $repo_name = $title, $gpg_id='', $gpg_key='') {
    include config

    $config_file     = "/etc/apt/sources.list.d/${repo_name}.list"

    # for the template
    $ipaddress       = $::ipaddress
    $apt_repo_server = $config::apt_repo_server
    # Precise doesn't support https at all
    $scheme          = $::operatingsystemrelease ? {
        12.04   => 'http',
        default => 'https'
    }

    # This class uses numeric user/group IDs since this resource is in the
    # 'packagesetup' state, which comes before the 'main' stage where
    # User['root'] occurs..

    file {
        $config_file:
            owner   => 0,
            group   => 0,
            mode    => '0644',
            notify  => Exec['apt-get-update'],
            content => template('packages/sources.list.erb');
    }

    if ($gpg_id) {
        if (!$gpg_key){
            fail("Cannot import GPG key: ${gpg_id}")
        }

        file {
            "/etc/apt/${repo_name}-pubkey.txt":
                source    => $gpg_key,
                owner     => 0,
                group     => 0,
                mode      => '0644',
                notify    => Exec["install-${repo_name}-repo-pubkey"],
                show_diff => false;
        }
        exec {
            "install-${repo_name}-repo-pubkey":
                command   => "/usr/bin/apt-key add /etc/apt/${repo_name}-pubkey.txt",
                logoutput => on_failure,
                unless    => "/usr/bin/apt-key list | /bin/grep -q '^pub.*/${gpg_id} '";
        }
    }
}
