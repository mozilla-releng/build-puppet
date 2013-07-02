# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class talos {
    include talos::settings
    include httpd
    include packages::xcode_cmdline_tools
    include packages::xvfb
    include users::builder
    include dirs::builds::slave

    # Due to different tests and flavors of tests run on different platforms,
    # each has a peculiar set of packages required, with little or no overlap.
    # This is the place to add such peculiarities, preferably commented with
    # the relevant bug.
    case $::operatingsystem {
        Ubuntu: {
            # Ubuntu specific packages
            include packages::nodejs
            include packages::llvm
            # required for the 32-bit reftests per :ahal, bug 837268
            include packages::ia32libs
            include packages::gstreamer
            include tweaks::cron
            include tweaks::resolvconf
            kernelmodule {
                "snd_aloop":
                    packages => ["libasound2"];
                "v4l2loopback":
                    packages => ["v4l2loopback-dkms"];
            }
        }
        Darwin: {
            # Darwin-specific packages
            include packages::javadeveloper_for_os_x
        }
    }

    case $::operatingsystem {
        Darwin, CentOS, Ubuntu: {
            file {
                ["/builds/slave/talos-slave",
                 "/builds/slave/talos-slave/talos-data",
                 $talos::settings::apachedocumentroot]:
                    ensure => directory,
                    owner => "$users::builder::username",
                    group => "$users::builder::group",
                    mode => 0755;
            }
            httpd::config {
                "talos.conf":
                    content => template("talos/talos-httpd.conf.erb") ;
            }
        }
    }
}
