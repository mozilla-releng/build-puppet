# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# A single class that installs the prerequisites for virtualenv, which vary per
# platform.  This way, other resources (in python27::virtualenv) can just require
# Class['python27::virtualenv::prerequisites'].
class python27::virtualenv::prerequisites {
    include python27::virtualenv::settings
    anchor {
        'python27::virtualenv::prerequisites::begin': ;
        'python27::virtualenv::prerequisites::end': ;
    }

    Anchor['python27::virtualenv::prerequisites::begin'] ->
    python27::misc_python_file {
        'virtualenv.py':
            source_file => "virtualenv-${python27::virtualenv::settings::virtualenv_version}/virtualenv.py",
            filename    => 'virtualenv.py',
            recurse     => false;
    } -> Anchor['python27::virtualenv::prerequisites::end']
    Anchor['python27::virtualenv::prerequisites::begin'] ->
    python27::misc_python_file {
        'virtualenv_support':
            source_file => "virtualenv-${python27::virtualenv::settings::virtualenv_version}/virtualenv_support",
            filename    => 'virtualenv_support',
            recurse     => true;
    } -> Anchor['python27::virtualenv::prerequisites::end']

}
