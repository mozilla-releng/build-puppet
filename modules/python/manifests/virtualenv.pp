# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/Puppet/Modules/python

# Install a virtualenv, based on a particular Python, and containing
# a particular set of packages.
#
# Package dependencies are not followed - list *all* required packages in the
# packages parameter.  Note that this cannot uninstall packages, although it
# can be used to upgrade/downgrade packages (as pip will automatically
# uninstall the previous version)
#
# title: virtualenv directory
# python: python executable on which to base the virtualenv
# ensure: present or absent
# packages: array of package names and versions to install
# user: username to own the virtualenv
# group: group to own the virtualenv
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
            case $kernel {
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
                            --python=$python --distribute $virtualenv",
                    user => $ve_user,
                    logoutput => on_failure,
                    require => [
                        File[$virtualenv],
                        Class['python::virtualenv::prerequisites'],
                    ],
                    creates => "$virtualenv/bin/pip";
            }

            # TODO: requires regsubst, which is not in 0.24.8:
#            # now install each package; we use regsubst to qualify the resource name
#            # with the virtualenv; a similar regsubst will be used in the python::virtualenv::package
#            # define to separate these two values
#            $qualified_packages = regsubst($packages, "^", "$virtualenv||")
#            python::virtualenv::package { $qualified_packages: }
            python::virtualenv::package {
                $packages: 
                    user => $ve_user,
                    virtualenv => $virtualenv;
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




