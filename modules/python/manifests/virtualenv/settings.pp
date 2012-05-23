# (private)
class python::virtualenv::settings {
    # the root package directory into which all Python package tarballs are copied
    $misc_python_dir = "/tools/misc-python"

    # the puppet URL for the python/packages downloads
    $packages_dir_source = "puppet:///python/packages"
}
