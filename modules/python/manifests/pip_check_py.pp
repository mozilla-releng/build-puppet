# (private)
#
# Install pip-check.py into the misc-python directory
class python::pip_check_py {
    include python::virtualenv::settings
    include python::misc_python_dir

    $file = "${python::virtualenv::settings::misc_python_dir}/pip-check.py"

    file {
        "$file":
            source => "puppet:///modules/python/pip-check.py",
            require => Class["python::misc_python_dir"];
    }
}

