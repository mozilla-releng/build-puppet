# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/Puppet/Modules/python
define python35::virtualenv($python3, $ensure='present', $packages=null, $user=null, $group=null, $mode='0755') {
    include python35::virtualenv::settings

    $virtualenv = $title
    $ve_cmd = $::operatingsystem ? {
        default => "${python3} -mvenv -- ${virtualenv}",
    }

    # Figure out user/group if they haven't been set
    # User and Group attributes are not support by Windows when using the exec resource
    case $::operatingsystem {
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
    case $ensure {
        present: {
            file {
                # create the virtualenv directory
                $virtualenv:
                    ensure => directory,
                    owner  => $ve_user,
                    group  => $ve_group,
                    mode   => $mode;
            }
            python35::virtualenv::package {
                "${virtualenv}||pip==${python35::virtualenv::settings::pip_version}":
                    user => $ve_user;
            }
            $os = $::operatingsystem ? {
                        windows => "${virtualenv}/Scripts/pip.exe",
                        default => "${virtualenv}/bin/pip"
            }
            exec {
                "virtualenv ${virtualenv}":
                    user      => $ve_user,
                    command   => $ve_cmd,
                    logoutput => on_failure,
                    require   => [
                        File[$virtualenv],
                    ],
                    creates   => $os,
                    cwd       => $virtualenv;
            }

            if ($packages != null) {
                # now install each package; we use regsubst to qualify the resource
                # name with the virtualenv; a similar regsubst will be used in the
                # python35::virtualenv::package define to separate these two values
                $qualified_packages = regsubst($packages, '^', "${virtualenv}||")
                python35::virtualenv::package {
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
