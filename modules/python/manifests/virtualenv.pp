# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/Puppet/Modules/python
define python::virtualenv($python, $ensure="present", $packages, $user=null, $group=null) {
    include python::virtualenv::settings
    include python::virtualenv::prerequisites

    $virtualenv = $title

    # Figure out user/group if they haven't been set
    case $user {
        null: {
            $ve_user = "root"
        }

        default: {
            $ve_user = $user
        }
    }
    case $group {
        null: {
            case $::kernel {
                Linux: {
                    $ve_group = "root"
                }
                Darwin: {
                    $ve_group = "admin"
                }
            }
        }

        default: {
            $ve_group = $group
        }
    }

    case $ensure {
        present: {
            file {
                # create the virtualenv directory
                "$virtualenv":
                    owner => $ve_user,
                    group => $ve_group,
                    ensure => directory;
            }

            exec {
                "virtualenv $virtualenv":
                    name => "$python -BE ${python::virtualenv::settings::misc_python_dir}/virtualenv.py \
                            --python=$python --distribute --never-download $virtualenv",
                    user => $ve_user,
                    logoutput => on_failure,
                    require => [
                        File[$virtualenv],
                        Class['python::virtualenv::prerequisites'],
                    ],
                    creates => "$virtualenv/bin/pip";
            }

            # now install each package; we use regsubst to qualify the resource
            # name with the virtualenv; a similar regsubst will be used in the
            # python::virtualenv::package define to separate these two values
            $qualified_packages = regsubst($packages, "^", "$virtualenv||")
            python::virtualenv::package {
                $qualified_packages:
                    user => $ve_user;
            }
        }

        absent: {
            # absent? that's easy - blow away the directory
            file {
                "$virtualenv":
                    ensure => absent,
                    backup => false,
                    force => true;
            }
        }
    }
}




