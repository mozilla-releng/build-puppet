# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/Puppet/Modules/python
define python27::virtualenv($python, $ensure='present', $packages=null, $user=null, $group=null, $rebuild_trigger=null) {
    include python27::virtualenv::settings
    include python27::virtualenv::prerequisites

    $virtualenv = $title
    $ve_cmd     = $::operatingsystem ? {
        # use --system-site-packages on Windows so that we can have access to pywin32, which
        # isn't pip-installable
        windows => "${python} -BE ${python27::virtualenv::settings::misc_python_dir}\\virtualenv.py --system-site-packages --python=${python} --distribute --never-download ${virtualenv}",
        default => "${python} -BE ${python27::virtualenv::settings::misc_python_dir}/virtualenv.py \
                                        --python=${python} --never-download ${virtualenv}",
    }

    # Figure out user/group if they haven't been set
    # User and Group attributes are not support by Windows when using the exec resource
    case $::operatingsystem {
        Windows: {
            $ve_user  = undef
            $ve_group = undef
        }
        default: {
            case $user {
                null: {
                    $ve_user = 'root'
                }
                default: {
                    $ve_user = $user
                }
            }
            case $group {
                null: {
                    case $::kernel {
                        Linux: {
                            $ve_group = 'root'
                        }
                        Darwin: {
                            $ve_group = 'admin'
                        }
                    }
                }

                default: {
                          $ve_group = $group
                }
            }
        }
    }
    # If a $rebuild_trigger was specified, we want to completely remove
    # the virtualenv, which will cause it to rebuilt from scratch
    if ($rebuild_trigger) {
        if ($::operatingsystem != Windows) {
            exec {
                "rebuild ${virtualenv}":
                    logoutput   => on_failure,
                    command     => "/bin/rm -rf ${virtualenv}/bin ${virtualenv}/include ${virtualenv}/lib ${virtualenv}/local ${virtualenv}/share ${virtualenv}/build",
                    subscribe   => [
                        $rebuild_trigger,
                        Python27::Misc_python_file["virtualenv.py"],
                        Python27::Misc_python_file["virtualenv_support"],
                    ],
                    refreshonly => true;
            }
        }
    }
    case $ensure {
        present: {
            if ($::operatingsystem != Windows) {
                file {
                    # create the virtualenv directory
                    $virtualenv:
                        ensure => directory,
                        owner  => $ve_user,
                        group  => $ve_group;
                }
            }
            else {
                file {
                    # create the virtualenv directory
                    $virtualenv:
                        ensure => directory,
                        owner  => $ve_user,
                        group  => $ve_group;
                }
            }
            exec {
                "virtualenv ${virtualenv}":
                    user      => $ve_user,
                    command   => $ve_cmd,
                    logoutput => on_failure,
                    require   => $::operatingsystem ? {
                        windows => [
                            File[$virtualenv],
                            Class['python27::virtualenv::prerequisites'],
                        ],
                        default => [
                            File[$virtualenv],
                            Class['python27::virtualenv::prerequisites'],
                            Exec["rebuild ${virtualenv}"],
                        ],
                    },
                    creates   => $::operatingsystem ? {
                        windows => "${virtualenv}/Scripts/pip.exe",
                        default => "${virtualenv}/bin/pip"
                    },
                    cwd       => $virtualenv;
            }

            if ($packages != null) {
                $lines = split($packages, "\n")
                # Get rid of lines that are just a comment
                $no_comment_lines = grep($lines, "^(?!#)")
                # Get rid of inline comments on package lines
                $parsed_packages = strip(regsubst($no_comment_lines, "#.*", ""))
                # now install each package; we use regsubst to qualify the resource
                # name with the virtualenv; a similar regsubst will be used in the
                # python27::virtualenv::package define to separate these two values
                $qualified_packages = regsubst($parsed_packages, '^', "${virtualenv}||")
                python27::virtualenv::package {
                    $qualified_packages:
                        user => $ve_user;
                }
            }
        }

        absent: {
            # absent? that's easy - blow away the directory
            file {
                $virtualenv:
                    ensure => absent,
                    backup => false,
                    force  => true;
            }
        }
    }
}
