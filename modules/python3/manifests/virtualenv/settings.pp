# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
class python3::virtualenv::settings {
    # the root package directory into which all Python package tarballs are copied
    $misc_python_dir     = $::operatingsystem ? {
        windows => 'c:\mozilla-build',
        default => '/tools/misc-python3',
    }
    # the puppet URL for the python/packages-3.x downloads
    $packages_dir_source = 'puppet:///python/packages-3.x'

    $virtualenv_version  = '16.0.0'
}
