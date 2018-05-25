# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
class python::virtualenv::settings {
    # the root package directory into which all Python package tarballs are copied
    $misc_python_dir = $::operatingsystem ? {
        windows => 'c:\mozilla-build',
        default => '/tools/misc-python',
    }
    # the puppet URL for the python/packages downloads
    $packages_dir_source = 'puppet:///python/packages'

    $pip_version         = $::operatingsystem ? {
        windows => '1.5.5',
        default => '10.0.1'
    }
    $setuptools_version  = '39.1.0'
    $wheel_version       = '0.31.1'
    $virtualenv_version  = '16.0.0'
}
