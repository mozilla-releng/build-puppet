# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ganglia {
    include ::config
    include users::root

    case $::config::org {
        moco: {
            include ganglia::install

            $mode = "mcast"
            # Mozilla configuration
            case $fqdn {
                /^.*\.srv\.releng\.scl3\.mozilla\.com$/: {
                    $cluster = "RelEngSCL3Srv"
                    $addr = "239.2.11.204"
                }
                /^.*\.build\.scl1\.mozilla\.com$/: {
                    $cluster = "RelEngSCL1"
                    $addr = "239.2.11.201"
                }
                /^.*\.releng\.scl1\.mozilla\.com$/: {
                    # note that there's no ganglia server in these VLANs, so this doesn't
                    # actually work, but it at least gets the hosts configured
                    $cluster = "RelEngSCL1"
                    $addr = "239.2.11.201"
                }
                /^.*\.build\.mtv1\.mozilla\.com$/: {
                    $cluster = "RelEngMTV1"
                    $addr = "239.2.11.203"
                }
                /^.*\.releng\.(use1|usw2)\.mozilla\.com$/: {
                    # this is a fake address, but we need sometihng to plug in here until
                    # we convert to using graphite
                    $cluster = "RelengAws"
                    $addr = "127.0.0.1"
                }
                default: {
                    fail("Unsupported ganglia fqdn")
                }
            }

            file {
                "/etc/ganglia/gmond.conf":
                    notify => Service['gmond'],
                    require => Class['packages::ganglia'],
                    content => template("ganglia/moco-gmond.conf.erb"),
                    owner => "root",
                    group => "$::users::root::group",
                    mode => 644;
            }
        }
        default: {
            # no ganglia, so don't install
        }
    }
}
