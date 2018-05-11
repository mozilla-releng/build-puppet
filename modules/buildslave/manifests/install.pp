# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildslave::install {
    include packages::mozilla::python27

    anchor {
        'buildslave::install::begin': ;
        'buildslave::install::end': ;
    }

    $version = '0.8.4-pre-moz11'

    $virtualenv_path = $::operatingsystem ? {
        windows => 'c:\mozilla-build\buildbotve',
        default => '/tools/buildbot',
    }

    $py_require = Class['packages::mozilla::python27']

    $external_packages = file("buildslave/requirements.txt")
    $packages = "${external_packages}buildbot==${version}\nbuildbot-slave==${version}"

    Anchor['buildslave::install::begin'] ->
    python::virtualenv {
        $virtualenv_path:
            python          => $::packages::mozilla::python27::python,
            rebuild_trigger => $py_require,
            require         => $py_require,
            packages        => $packages;
    } -> Anchor['buildslave::install::end']
}
