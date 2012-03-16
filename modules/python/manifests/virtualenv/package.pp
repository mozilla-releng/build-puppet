# (private)
#
# Install the given Python package into the given virtualenv.
define python::virtualenv::package($user) {
    include python::virtualenv::settings
    include python::misc_python_dir
    include python::pip_check_py

    # extract the virtualenv and tarball from the title
    $virtualenv = regsubst($title, "\\|\\|.*$", "")
    $pkg = regsubst($title, "^.*\\|\\|", "")

    $pip_check_py = $python::pip_check_py::file
    $pkg_http = $python::virtualenv::settings::packages_dir_http
    $pip_options = "--no-deps --no-index --find-links $pkg_http"

    exec {
        # point pip at the package directory so that it can select the best option
        "pip $title":
            name => "$virtualenv/bin/pip install $pip_options $pkg",
            logoutput => on_failure,
            onlyif => "$virtualenv/bin/python $pip_check_py $pkg",
            user => $user,
            require => [
                Class['python::pip_check_py'],
                Exec["virtualenv $virtualenv"],
            ];
    }
}

