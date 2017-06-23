# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets($slave_type, $ensure=present) {

    include dirs::etc

    # check that the node-level variable is set
    if ($slave_trustlevel == '') {
        fail('No slave_trustlevel is set for this host; add that to your node definition')
    }

    # compare the existing trustlevel to the specified; if they're not the same, we're in trouble
    if ($::existing_slave_trustlevel != '' and $::existing_slave_trustlevel != $slave_trustlevel) {
        fail("This host used to have trust level ${::existing_slave_trustlevel}, and cannot be changed to ${slave_trustlevel} without a reimage")
    }

    # set the on-disk trust level if it's not already defined
    $trustlevel_file =  $::operatingsystem ? {
        windows => 'C:/etc/slave-trustlevel',
        default => '/etc/slave-trustlevel',
    }

    file {
        $trustlevel_file:
            content => $slave_trustlevel,
            replace => false,
            mode    => filemode(0500),
            require => Class[dirs::etc],
    }

    # actually do the work of installing, or removing, secrets
    case $ensure {
        present: {
            class {
                'slave_secrets::ssh_keys':
                    slave_type => $slave_type;
            }
        }
        absent: {
            # ssh keys are purged by ssh::userconfig
        }
    }

    class {
        'slave_secrets::relengapi_token':
            ensure => $ensure;
    }

    # install the following secrets only on build slaves
    # * google API key
    # * google oauth API
    # * ceph credentials
    # * mozilla API
    # * crash stats API token
    # * Adjust SDK token
    # * Release automation S3 credentials
    if ($slave_type == 'build') {
        class {
            'slave_secrets::google_api_key':
                ensure => $ensure;
            'slave_secrets::google_oauth_api_key':
                ensure => $ensure;
            'slave_secrets::ceph_config':
                ensure => $ensure;
            'slave_secrets::mozilla_geoloc_api_keys':
                ensure => $ensure;
            'slave_secrets::crash_stats_api_token':
                ensure => $ensure;
            'slave_secrets::adjust_sdk_token':
                ensure => $ensure;
            'slave_secrets::release_s3_credentials':
                ensure => $ensure;
        }
    } else {
        class {
            'slave_secrets::google_api_key':
                ensure => absent;
            'slave_secrets::google_oauth_api_key':
                ensure => absent;
            'slave_secrets::ceph_config':
                ensure => absent;
            'slave_secrets::mozilla_geoloc_api_keys':
                ensure => absent;
            'slave_secrets::crash_stats_api_token':
                ensure => absent;
            'slave_secrets::adjust_sdk_token':
                ensure => absent;
            'slave_secrets::release_s3_credentials':
                ensure => absent;
        }
    }
}
