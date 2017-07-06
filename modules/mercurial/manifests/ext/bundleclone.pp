# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mercurial::ext::bundleclone {
    include mercurial::ext::common

    file {
        "${mercurial::settings::hgext_dir}/bundleclone.py":
            source => 'puppet:///modules/mercurial/bundleclone.py';
    }
    if ($::operatingsystem == Windows) {
        acl {
            "${mercurial::settings::hgext_dir}/bundleclone.py":
                purge                      => true,
                inherit_parent_permissions => false,
                # indentation of => is not properly aligned in hash within array: The solution was provided on comment 2
                # https://github.com/rodjek/puppet-lint/issues/333
                permissions                => [
                    {
                      identity => 'root',
                      rights   => ['full'] },
                    {
                      identity => 'SYSTEM',
                      rights   => ['full'] },
                    {
                      identity => 'cltbld',
                      rights   => ['full'] },
                ];
        }
    }
}
