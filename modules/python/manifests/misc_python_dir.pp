# (private)
#
# Ensure that this module's misc directory exists
class python::misc_python_dir {
    include python::virtualenv::settings
    include dirs::tools # assuming this dir is under /tools

    file {
        "${python::virtualenv::settings::misc_python_dir}":
            ensure => directory;
    }
}

