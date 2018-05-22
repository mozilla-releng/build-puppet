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
        'virtualenv.py':
            source_file => "virtualenv-${python::virtualenv::settings::virtualenv_version}/virtualenv.py",
            filename    => "virtualenv.py";
    } -> Anchor['python::virtualenv::prerequisites::end']

    # these two need to be in the same dir as virtualenv.py, or it will
    # want to download them from pypi
    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        "pip":
            source_file => "virtualenv-${python::virtualenv::settings::virtualenv_version}/pip-${python::virtualenv::settings::pip_version}-py2.py3-none-any.whl",
            filename    => "pip-${python::virtualenv::settings::pip_version}-py2.py3-none-any.whl";
    } -> Anchor['python::virtualenv::prerequisites::end']
    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        "setuptools":
            source_file => "virtualenv-${python::virtualenv::settings::virtualenv_version}/setuptools-${python::virtualenv::settings::setuptools_version}-py2.py3-none-any.whl",
            filename    => "setuptools-${python::virtualenv::settings::setuptools_version}-py2.py3-none-any.whl";
    } -> Anchor['python::virtualenv::prerequisites::end']
    Anchor['python::virtualenv::prerequisites::begin'] ->
    python::misc_python_file {
        "wheel":
            source_file => "virtualenv-${python::virtualenv::settings::virtualenv_version}/wheel-${python::virtualenv::settings::wheel_version}-py2.py3-none-any.whl",
            filename    => "wheel-${python::virtualenv::settings::wheel_version}-py2.py3-none-any.whl";
    } -> Anchor['python::virtualenv::prerequisites::end']
}
