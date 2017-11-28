# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
#
# Install pip-check.py into the misc-python directory
class python27::pip_check_py {
    include python27::virtualenv::settings
    include python27::misc_python_dir
    include users::root

    $file = "${python27::virtualenv::settings::misc_python_dir}/pip-check.py"

    file {
        $file:
            source  => 'puppet:///modules/python27/pip-check.py',
            owner   => root,
            group   => $::users::root::group,
            mode    => filemode(0644),
            require => Class['python27::misc_python_dir'];
    }
}
