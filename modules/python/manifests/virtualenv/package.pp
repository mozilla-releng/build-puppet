# (private)
#
# Install the given Python package into the given virtualenv.
define python::virtualenv::package($virtualenv, $user) { # TODO: extract $virtualenv from $title (see above)
    include python::virtualenv::settings
    include python::misc_python_dir
    include python::pip_check_py

    # TODO: requires regsubst, which is not in 0.24.8:
#    # extract the virtualenv and tarball from the title
#    $virtualenv = regsubst($title, "\|\|.*$", "")
#    $pkg = regsubst($title, "^.*\|\|", "")
    $pkg = $title

    $pip_check_py = $python::pip_check_py::file

    exec {
        # point pip at the package directory so that it can select the best option
        "pip-$virtualenv||$pkg":
            name => "$virtualenv/bin/pip install \
                    --no-deps --no-index \
                    --find-links=${python::virtualenv::settings::packages_dir_http} \
                    $pkg",
            logoutput => on_failure,
            onlyif => "$virtualenv/bin/python $pip_check_py $pkg",
            user => $user,
            require => [
                Class['python::pip_check_py'],
                Exec["virtualenv $virtualenv"],
            ];
    }
}

