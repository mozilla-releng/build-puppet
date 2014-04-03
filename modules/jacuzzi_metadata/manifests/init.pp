# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class jacuzzi_metadata {
    # AWS machines should fetch jacuzzi metadata and dump it in /etc/jacuzzi_metadata.json
    include packages::mozilla::py27_mercurial
    $python = $::packages::mozilla::python27::python

    file {
        "/usr/local/bin/jacuzzi_metadata.py":
            owner  => "root",
            mode   => 0755,
            source => "puppet:///modules/jacuzzi_metadata/jacuzzi_metadata.py",
            require  => Class['packages::mozilla::python27'];
    }

    # On Linux systems, run from init.d on boot
    case $::operatingsystem {
        Ubuntu, CentOS: {
            file {
                "/etc/init.d/jacuzzi_metadata":
                    require => File["/usr/local/bin/jacuzzi_metadata.py"],
                    content => template("jacuzzi_metadata/jacuzzi_metadata.initd.erb"),
                    mode    => 0755,
                    owner   => "root",
                    notify  => Service["jacuzzi_metadata"];
            }
            service {
                "jacuzzi_metadata":
                    require => [
                        File["/etc/init.d/jacuzzi_metadata"],
                        File["/usr/local/bin/jacuzzi_metadata.py"],
                    ],
                    hasstatus => false,
                    enable    => true;
            }
            # Run this from exec so that we get it at least once when puppet runs the first time.
            exec {
                "get_jacuzzi_metadata":
                    require => File["/usr/local/bin/jacuzzi_metadata.py"],
                    creates => "/etc/jacuzzi_metadata.json",
                    user    => "root",
                    command => "$python /usr/local/bin/jacuzzi_metadata.py -o /etc/jacuzzi_metadata.json";
            }
        }
        default: {
            # TODO: Put this into a proper service
            exec {
                "get_jacuzzi_metadata":
                    require => File["/usr/local/bin/jacuzzi_metadata.py"],
                    user    => "root",
                    command => "$python /usr/local/bin/jacuzzi_metadata.py -o /etc/jacuzzi_metadata.json";
            }
        }
    }
}
