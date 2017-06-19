# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::ssl {
    include ::config
    include puppetmaster::puppetsync_user
    include puppetmaster::install
    include puppetmaster::settings
    include puppetmaster::dirs

    # start by defining some paths that are also used elsewhere
    $dir                           = "${puppetmaster::settings::puppetmaster_root}/ssl"

    # ca/ contains the info required for signing leaf certs
    $ca_dir                        = "${dir}/ca"

    # pvt/ contains private stuff for this master
    $pvt_dir                       = "${dir}/pvt"
    $master_ca_key                 = "${pvt_dir}/master-ca.key"
    $master_key                    = "${pvt_dir}/master.key"

    # git/ is the git repo synchronized among all masters
    $git_dir                       = "${dir}/git"
    $git_config                    = "${git_dir}/.git/config"

    # hashed dir of all CA certs and CRLs
    $certdir                       = "${git_dir}/certdir"
    # all agent certs, by issuing master
    $agent_certs_dir               = "${git_dir}/agent-certs"
    # agent certs from this master
    $my_agent_certs_dir            = "${agent_certs_dir}/${::fqdn}"
    # requests for revocation, by issuing master
    $revocation_requests_dir       = "${git_dir}/revocation-requests"
    # revocation requests for this master's issued certs
    $my_revocation_requests_dir    = "${revocation_requests_dir}/${::fqdn}"
    # ca certificates
    $ca_certs_dir                  = "${git_dir}/ca-certs"
    # leaf certs for each master
    $master_certs_dir              = "${git_dir}/master-certs"

    # git-common is a bare repo used as part of the synchronization
    $git_common_dir                = "${dir}/git-common"
    $git_common_config             = "${git_common_dir}/config"

    # this master's certificate
    $master_cert                   = "${master_certs_dir}/${::fqdn}.crt"
    $puppetmaster_cert_extra_names = $::config::puppetmaster_cert_extra_names
    # the master's CA certificate and CRL
    $master_ca_cert                = "${ca_certs_dir}/${::fqdn}.crt"
    $master_ca_crl                 = "${ca_certs_dir}/${::fqdn}.crl"
    # the root CA certificate and CRL
    $root_ca_cert                  = "${ca_certs_dir}/root.crt"
    $root_ca_crl                   = "${ca_certs_dir}/root.crl"

    $scripts_dir                   = "${dir}/scripts"

    $tmp_dir                       = "${dir}/tmp"

    # restart Apache during a normal-ish working hour
    $restart_hour                  = fqdn_rand(8) + 7

    # set up all of those dirs, including .keep files to convince git to ship
    # directories around
    file {
        $dir:
            ensure => directory,
            owner  => puppet,
            group  => puppet,
            mode   => '0771'; # this is the mode puppet likes to enforce on its ssldir

        [ $ca_dir, $git_dir, $agent_certs_dir,
          $my_agent_certs_dir, $revocation_requests_dir,
          $my_revocation_requests_dir, $ca_certs_dir,
          $master_certs_dir, $git_common_dir, $scripts_dir,
          $tmp_dir ]:
            ensure => directory,
            owner  => 'puppetsync',
            group  => 'puppetsync',
            before => Exec['puppetmaster-ssl-git-init'];

        $pvt_dir:
            ensure => directory,
            mode   => '0700',
            before => Exec['puppetmaster-ssl-git-init'];

        # set up the git config
        $git_config:
            content => template("${module_name}/ssl_git_config.erb"),
            owner   => 'puppetsync',
            group   => 'puppetsync',
            require => Exec['puppetmaster-ssl-git-init'];
        $git_common_config:
            content => template("${module_name}/ssl_git_config.erb"),
            owner   => 'puppetsync',
            group   => 'puppetsync',
            require => Exec['puppetmaster-ssl-git-common-init'];

        # libraries
        "${scripts_dir}/ssl_common.sh":
            content => template("${module_name}/ssl_common.sh.erb");
        "${scripts_dir}/git_common.sh":
            content => template("${module_name}/git_common.sh.erb");
        "${scripts_dir}/vars.sh":
            content => template("${module_name}/vars.sh.erb");

        # initial setup scripts (used during bootstrapping)
        "${scripts_dir}/ssl_setup.sh":
            content => template("${module_name}/ssl_setup.sh.erb"),
            mode    => '0755';
        "${scripts_dir}/ssl_setup_root.sh":
            content => template("${module_name}/ssl_setup_root.sh.erb"),
            mode    => '0755';
        "${scripts_dir}/make_master_cert.sh":
            content => template("${module_name}/make_master_cert.sh.erb"),
            mode    => '0755';

        # synchronize git repositories regularly
        "${scripts_dir}/ssl_git_sync.sh":
            content => template("${module_name}/ssl_git_sync.sh.erb"),
            mode    => '0755';
        '/etc/cron.d/ssl_git_sync':
            content => template("${module_name}/ssl_git_sync.cron.erb");

        # git utility scripts
        "${scripts_dir}/add_file_to_git.sh":
            content => template("${module_name}/add_file_to_git.sh.erb"),
            mode    => '0755';
        "${scripts_dir}/rm_file_from_git.sh":
            content => template("${module_name}/rm_file_from_git.sh.erb"),
            mode    => '0755';
        "${scripts_dir}/mv_file_in_git.sh":
            content => template("${module_name}/mv_file_in_git.sh.erb"),
            mode    => '0755';

        # the cert-granting script used by the getcert CGI
        "${scripts_dir}/deployment_getcert.sh":
            content => template('puppetmaster/deployment_getcert.sh.erb'),
            mode    => '0755';

        # a revocation command for users
        '/usr/local/sbin/revoke-cert':
            content => template('puppetmaster/revoke-cert.erb'),
            mode    => '0755';

        # perform all revocations requested on other masters hourly
        "${scripts_dir}/do_requested_revocations.sh":
            content => template("${module_name}/do_requested_revocations.sh.erb"),
            mode    => '0755';
        '/etc/cron.d/puppetmaster-do-requested-revocations':
            content => "10 * * * * root ${scripts_dir}/do_requested_revocations.sh\n";

        # Apache doesn't reload CRLs unless it's restarted, so we restart once a day.
        # see https://issues.apache.org/bugzilla/show_bug.cgi?id=14104
        '/etc/cron.d/puppetmaster-restart-apache':
            content => "10 ${restart_hour} * * * root /usr/sbin/apachectl restart 2>/dev/null >/dev/null\n";

        # old files
        '/etc/cron.d/puppetmaster-ssl-git-perms':
            ensure => absent;
    }

    exec {
        # initialize the two git repositories
        'puppetmaster-ssl-git-init':
            command   => '/usr/bin/git init',
            cwd       => $git_dir,
            user      => 'puppetsync',
            group     => 'puppetsync',
            require   => [
                Class['packages::mozilla::git'],
                File[$git_dir]
            ],
            logoutput => true,
            creates   => "${git_dir}/.git";

        'puppetmaster-ssl-git-common-init':
            command   => '/usr/bin/git init --bare',
            cwd       => $git_common_dir,
            user      => 'puppetsync',
            group     => 'puppetsync',
            require   => [
                Class['packages::mozilla::git'],
                File[$git_common_dir]
            ],
            logoutput => true,
            creates   => "${git_common_dir}/config";

        # set up their initial contents
        'puppetmaster-ssl-setup':
            command   => "${scripts_dir}/ssl_setup.sh",
            user      => 'puppetsync',
            group     => 'puppetsync',
            require   => [
                Exec['puppetmaster-ssl-git-common-init'],
                Exec['puppetmaster-ssl-git-init'],
                File[$git_config],
                File["${scripts_dir}/ssl_setup.sh"],
                File["${scripts_dir}/git_common.sh"],
                Class['packages::procmail'], # for lockfile
            ],
            logoutput => true,
            creates   => "${ca_dir}/.setup-complete";

        'puppetmaster-ssl-setup-root':
            command   => "${scripts_dir}/ssl_setup_root.sh",
            require   => [
                Exec['puppetmaster-ssl-setup'],
                File["${scripts_dir}/ssl_setup_root.sh"],
                File["${scripts_dir}/ssl_common.sh"],
                File["${scripts_dir}/add_file_to_git.sh"],
            ],
            logoutput => true,
            creates   => "${ca_dir}/.setup-root-complete";

        # and create the master cert (as root)
        'puppetmaster-ssl-make-master-cert':
            command   => "${scripts_dir}/make_master_cert.sh",
            require   => [
                Exec['puppetmaster-ssl-setup-root'],
                File["${scripts_dir}/make_master_cert.sh"],
                File["${scripts_dir}/git_common.sh"],
                File["${scripts_dir}/ssl_common.sh"],
                Class['packages::procmail'], # for lockfile
            ],
            logoutput => true,
            creates   => $master_cert;
    }
}
