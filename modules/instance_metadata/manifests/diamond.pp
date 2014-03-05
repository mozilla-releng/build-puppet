# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Enables submission of instance metadata to graphite via diamond
class instance_metadata::diamond {
    include diamond
    include instance_metadata
    file {
        "/usr/share/diamond/collectors/instance_metadata":
            ensure => directory,
            owner  => "root";

        "/usr/share/diamond/collectors/instance_metadata/instance_metadata.py":
            source => "puppet:///modules/instance_metadata/instance_metadata_collector.py",
            owner  => "root",
            mode   => 0755;

        "/etc/diamond/collectors/InstanceMetadataCollector.conf":
            source => "puppet:///modules/instance_metadata/InstanceMetadataCollector.conf",
            owner  => "root",
            mode   => 0755;
    }
}
