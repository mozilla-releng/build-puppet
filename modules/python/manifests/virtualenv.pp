# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/Puppet/Modules/python
define python::virtualenv($python, $ensure='present', $packages=null, $user=null, $group=null) {
    include python::virtualenv::settings
    include python::virtualenv::prerequisites

    $virtualenv = $title
    $ve_cmd     = $::operatingsystem ? {
        # use --system-site-packages on Windows so that we can have access to pywin32, which
        # isn't pip-installable
        windows => "${python} -BE ${python::virtualenv::settings::misc_python_dir}\\virtualenv.py --system-site-packages --python=${python} --distribute --never-download ${virtualenv}",
        default => "${python} -BE ${python::virtualenv::settings::misc_python_dir}/virtualenv.py \
                                        --python=${python} --distribute --never-download ${virtualenv}",
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
    case $ensure {
        present: {
            file {
                # create the virtualenv directory
                $virtualenv:
                    ensure => directory,
                    owner  => $ve_user,
                    group  => $ve_group;
            }
            python::virtualenv::package {
                "${virtualenv}||pip==${python::virtualenv::settings::pip_version}":
                    user => $ve_user;
            }
            exec {
                "virtualenv ${virtualenv}":
                    user      => $ve_user,
                    command   => $ve_cmd,
                    logoutput => on_failure,
                    require   => [
                        File[$virtualenv],
                            Class['python::virtualenv::prerequisites'],
                    ],
                    creates   => $::operatingsystem ? {
                        windows => "${virtualenv}/Scripts/pip.exe",
                        default => "${virtualenv}/bin/pip"
                    },
                    cwd       => $virtualenv;
            }

            if ($packages != null) {
                # now install each package; we use regsubst to qualify the resource
                # name with the virtualenv; a similar regsubst will be used in the
                # python::virtualenv::package define to separate these two values
                $qualified_packages = regsubst($packages, '^', "${virtualenv}||")
                python::virtualenv::package {
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
