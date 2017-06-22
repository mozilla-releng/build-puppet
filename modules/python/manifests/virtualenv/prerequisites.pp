# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# A single class that installs the prerequisites for virtualenv, which vary per
# platform.  This way, other resources (in python::virtualenv) can just require
# Class['python::virtualenv::prerequisites'].
class python::virtualenv::prerequisites {
    include python::virtualenv::settings
    anchor {
        'python::virtualenv::prerequisites::begin': ;
        'python::virtualenv::prerequisites::end': ;
    }

    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        'virtualenv.py': ;
    } -> Anchor['python::virtualenv::prerequisites::end']

    # these two need to be in the same dir as virtualenv.py, or it will
    # want to download them from pypi
    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        "pip-${python::virtualenv::settings::pip_version}.tar.gz": ;
    } -> Anchor['python::virtualenv::prerequisites::end']
    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        'distribute-0.6.24.tar.gz': ; # the virtualenv.py above looks for this version
    } -> Anchor['python::virtualenv::prerequisites::end']
}
