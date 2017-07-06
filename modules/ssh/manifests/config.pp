# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ssh::config {
    include users::root
    include ssh::settings
    include ssh::service
    include ::config

    case $::operatingsystem {
        CentOS: {
            # enable sftp sybsystem on CentOS
            $sftp_line = 'Subsystem sftp /usr/libexec/openssh/sftp-server'
        }
    }

    case $::operatingsystem {
        Windows: {
            include packages::kts

            $publickey_logon_ini = 'C:/Program Files/KTS/publickey_logon.ini'
            $rsakey_ky           = 'C:/Program Files/KTS/rsakey.ky'
            $kts_ini             = 'C:/Program Files/KTS/kts.ini'

            file {
                $ssh::settings::genkey_dir:
                    ensure => directory;
            }

            # install kts.ini
            file {
                'C:/Program Files/KTS/kts.ini':
                    content   => template("${module_name}/kts.ini.erb"),
                    show_diff => false,
                    notify    => Service['KTS'],
            }

            # generate a server key for KTS
            exec {
                'RSAkey':
                    command => '"C:\Program Files\KTS\daemon.exe" -rsakey',
                    require => Class['packages::kts'],
                    notify  => Service['KTS'],
                    creates => $rsakey_ky;
            }

            # install the logon batch file which will share the MOTD file
            file {
                'C:/Program Files/KTS/Scripts/allusers.bat':
                    source  => 'puppet:///modules/ssh/allusers.bat',
                    replace => true,
                    require => Class['packages::kts'];
            }

            # regenerate publickey_logon_ini; this is connected to everything
            # that would modify C:\Program Files\KTS\*.keys (from
            # ssh::userconfig and ssh::extra_authorized_key) or C:\Program
            # Files\KTS\*.pass (from users::{root,builder,etc.}
            file {
                "${::ssh::settings::genkey_dir}/genkeys.rb":
                    source  => 'puppet:///modules/ssh/genkeys.rb',
                    require => Class['packages::kts'];
            }
            exec {
                'generate-kts-publickey-logon-ini':
                    command     => "\"${::ruby_interpreter}\" genkeys.rb -o ../publickey_logon.ini",
                    cwd         => $ssh::settings::genkey_dir,
                    require     => File["${::ssh::settings::genkey_dir}/genkeys.rb"],
                    refreshonly => true,
                    logoutput   => true;
            }

            # finally, ensure that all of the files with passwords in them are
            # readable only by SYSTEM and root (and in particular, not the builder)
            acl {
                [$publickey_logon_ini, $ssh::settings::genkey_dir, $rsakey_ky, $kts_ini]:
                    purge                      => true,
                    inherit_parent_permissions => false,
                    require                    => [ Exec['generate-kts-publickey-logon-ini'],
                                                    File[$ssh::settings::genkey_dir],
                                                    Exec[ 'RSAkey'],
                                                    File[$kts_ini],
                                                  ],
                    # indentation of => is not properly aligned in hash within array: The solution was provided on comment 2
                    # https://github.com/rodjek/puppet-lint/issues/333
                    permissions                => [
                        {
                          identity => 'root',
                          rights   => ['full'] },
                        {
                          identity => 'SYSTEM',
                          rights   => ['full'] },
                    ];
            }
        }

        default: {
            # Duo MFA requires special sshd configuration
            $sshd_config_content = $duo_enabled ? {
                true    => template("${module_name}/sshd_config_duo.erb"),
                default => template("${module_name}/sshd_config.erb")
            }

            file {
                $ssh::settings::ssh_config:
                    owner   => $users::root::username,
                    group   => $users::root::group,
                    mode    => '0644',
                    content => template("${module_name}/ssh_config.erb");
                $ssh::settings::sshd_config:
                    owner   => $::users::root::username,
                    group   => $::users::root::group,
                    mode    => '0644',
                    notify  => Class['ssh::service'], # restart daemon if necessary
                    content => $sshd_config_content;
                $ssh::settings::known_hosts:
                    owner   => $::users::root::username,
                    group   => $::users::root::group,
                    mode    => '0644',
                    content => template("${module_name}/known_hosts.erb");
            }
        }
    }
}
