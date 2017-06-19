# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mockbuild {
    include packages::mozilla::mock_mozilla
    include mockbuild::services

    file {
        # make sure that the directory exists for cases when
        # /builds/mock_mozilla is mounted on a non persistent volumes (like EC2
        # instance storage)
        '/builds/mock_mozilla':
            ensure  => directory,
            require => Class['packages::mozilla::mock_mozilla'],
            owner   => 'root',
            group   => 'mock_mozilla',
            mode    => '2775';
    }
}
