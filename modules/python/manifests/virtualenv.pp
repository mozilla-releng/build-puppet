# Handle installing Python virtualenvs containing Python packages.
# https://wiki.mozilla.org/ReleaseEngineering/How_To/Install_a_Python_Virtualenv_with_Puppet
#
# EXAMPLES:
#
#   python::virtualenv {
#       "/path/to/virtualenv":
#           python => "/path/to/python",
#           packages => [ "package==version", "mock==0.6.0",
#                         "buildbot==0.8.0" ];
#   }
#
# or, to remove a virtualenv,
#
#   python::virtualenv {
#       "/path/to/virtualenv":
#           ensure => absent;
#   }
#
# NOTES
#
# Specify the packages using the pypi "==" notation; do NOT use any other operator,
# e.g., "=>" or an unqualified package name.
#
# An appropriate package file for the system must be available in the python
# package directory.  For pure-python packages, this can be an sdist tarball or
# zip; for packages that include some compiled source (e.g., Twisted), this
# will need to be a binary distribution, customized for the particular Python
# version and platform.
#
# On the masters, the package directory is at
#  /N/staging/python-packages
#  /N/production/python-packages
#  /builds/production/python-packages
# depending on the master.
#
# DEPENDENCIES
#
# - The global $level variable, which should be factored out
# - various Python installation stuff elsewhere in the manifests (see $virtualenv_reqs)
#
# TODO:
#  - use regsubst() to qualify python::package names so that the same package can
#    be installed in multiple virtualenvs (see commented-out stuff below)

class python::virtualenv::settings {
    # the root package directory into which all Python package tarballs are copied
    $misc_python_dir = "/tools/misc-python"
    # the source URL for it
    $package_dir_source = "puppet:///$level/python-packages"
    # the http URL for it
    $package_dir_http = "http://${puppetServer}/$level/python-packages"
}

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
define python::virtualenv($python, $ensure="present", $packages, $user=null, $group=null) {
    include python::virtualenv::settings

    $virtualenv = $title

    # calculate the set of stuff that has to be up before we can run a
    # virtualenv; this varies per platform.  Puppet does not support any kind of
    # append or concatenation on arrays (at least, not without lots of gymnastics
    # involving extra classes), so we put these common resources in variables
    # for brevity
    $virtualenv_dir_req = File["$virtualenv"]
    $pip_req = Python::Package_dir_file["pip-0.8.2.tar.gz"]
    $distribute_req = Python::Package_dir_file["distribute-0.6.14.tar.gz"]
    $virtualenv_py_req = Python::Package_dir_file["virtualenv.py"]

    # Figure out user/group if they haven't been set
    case $user {
        null: {
            case $kernel {
                Linux: {
                    $ve_user = "root"
                }
                Darwin: {
                    $ve_user = "root"
                }
            }
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

    # Set up the prerequisites for building a virtualenv, which differ
    # slightly per platform
    case $operatingsystem {
        Fedora: {
            $virtualenv_reqs = [
                Package['python-devel'],
                $virtualenv_dir_req,
                $pip_req,
                $distribute_req,
                $virtualenv_py_req,
            ]
        }

        default: {
            $virtualenv_reqs = [
                $virtualenv_dir_req,
                $pip_req,
                $distribute_req,
                $virtualenv_py_req,
            ]
        }
    }

    # instantiate the common requirements
    python::package_dir_file {
        # these two need to be in the same dir as virtualenv.py, or it will
        # want to download them from pypi
        "pip-0.8.2.tar.gz": ;
        "distribute-0.6.14.tar.gz": ;
        "virtualenv.py": ;
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
                    name => "$python ${python::virtualenv::settings::misc_python_dir}/virtualenv.py \
                            --python=$python --distribute $virtualenv",
                    user => $ve_user,
                    logoutput => on_failure,
                    require => $virtualenv_reqs,
                    creates => "$virtualenv/bin/pip";
            }

            # TODO: requires regsubst, which is not in 0.24.8:
#            # now install each package; we use regsubst to qualify the resource name
#            # with the virtualenv; a similar regsubst will be used in the python::package
#            # define to separate these two values
#            $qualified_packages = regsubst($packages, "^", "$virtualenv||")
#            python::package { $qualified_packages: }
            python::package {
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

# (private)
#
# Install pip-check.py into the misc-python directory
class python::pip_check_py {
    include python::virtualenv::settings
    include python::misc_python_dir

    file {
        "${python::virtualenv::settings::misc_python_dir}/pip-check.py":
            source => "puppet:///python/pip-check.py",
            require => [
                File["${python::virtualenv::settings::misc_python_dir}"],
            ];
    }
}

# (private)
#
# Ensure that the python package directory exists
class python::misc_python_dir {
    include python::virtualenv::settings

    file {
        "${python::virtualenv::settings::misc_python_dir}":
            ensure => directory;
    }
}

# (private)
#
# Download a file from the package dir into the misc-python directory.  This should be
# used sparingly - pip should download most mackages on its own.
define python::package_dir_file {
    include python::virtualenv::settings
    include python::misc_python_dir

    $filename = $title

    file {
        "${python::virtualenv::settings::misc_python_dir}/$filename": 
            source => "${python::virtualenv::settings::package_dir_source}/$filename",
            backup => false,
            require => [
                File["${python::virtualenv::settings::misc_python_dir}"],
            ];
    }
}

# (private)
#
# Install the given Python package into the given virtualenv.
define python::package($virtualenv, $user) { # TODO: extract $virtualenv from $title (see above)
    include python::virtualenv::settings
    include python::misc_python_dir
    include python::pip_check_py

    # TODO: requires regsubst, which is not in 0.24.8:
#    # extract the virtualenv and tarball from the title
#    $virtualenv = regsubst($title, "\|\|.*$", "")
#    $pkg = regsubst($title, "^.*\|\|", "")
    $pkg = $title

    $pip_check_py = "${python::virtualenv::settings::misc_python_dir}/pip-check.py"

    exec {
        # point pip at the package directory so that it can select the best option
        "pip-$virtualenv||$pkg":
            name => "$virtualenv/bin/pip install \
                    --no-deps --no-index \
                    --find-links=${python::virtualenv::settings::package_dir_http} \
                    $pkg",
            logoutput => on_failure,
            onlyif => "$virtualenv/bin/python $pip_check_py $pkg",
            user => $user,
            require => [
                File[$pip_check_py],
                Exec["virtualenv $virtualenv"],
            ];
    }
}
