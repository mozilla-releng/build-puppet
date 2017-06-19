# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define pkgbuilder::base_cow {
    include packages::cowbuilder

    # extract distribution and arch from the resource name
    $re           = '^([a-z]+)-([a-z0-9_]+)$'
    $distribution = regsubst($name, $re, '\1')
    $arch         = regsubst($name, $re, '\2')
    if ($distribution == $name) {
        fail("invalid pkgbuilder::base_cow name '${name}'")
    }

    $basepath     = "/var/cache/pbuilder/${distribution}-${arch}"

    exec {
        "setup-cowbuilder-${distribution}-${arch}":
            command   => "/usr/sbin/cowbuilder --create --distribution ${distribution} --architecture ${arch} --basepath ${basepath}",
            creates   => $basepath,
            logoutput => true,
            require   => Class['packages::cowbuilder'];
        "update-cowbuilder-${distribution}-${arch}":
            command     => "/usr/sbin/cowbuilder --update --distribution ${distribution} --architecture ${arch} --basepath ${basepath}",
            refreshonly => true,
            logoutput   => true,
            subscribe   => File['/etc/pbuilderrc'],
            require     => [
                Class['packages::cowbuilder'],
                Exec["setup-cowbuilder-${distribution}-${arch}"],
            ];
    }
}
