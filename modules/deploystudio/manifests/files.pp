# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class deploystudio::files {
    include deploystudio::settings

    $files_dir = "${deploystudio::settings::deploy_dir}/Files"

    # Make sure deploypass is set in hiera
    if secret('deploy_password') == '' {
        fail('missing deploy_password')
    }
    $deploy_password = secret('deploy_password')

    file {
        $files_dir:
            ensure => directory;
    } ->
    file {
        "${files_dir}/puppetize.sh":
            ensure => present,
            source => 'puppet:///modules/puppet/puppetize.sh';

        "${files_dir}/org.mozilla.puppetize.plist":
            ensure => present,
            source => 'puppet:///modules/puppet/org.mozilla.puppetize.plist';

        "${files_dir}/deploypass":
            ensure    => present,
            show_diff => false,
            content   => "${deploy_password}\n";
    }
}

