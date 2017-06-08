# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define bors::status($owner, $group, $repo_owner, $repo, $status_location) {
    file {
        $status_location:
            ensure => directory,
            owner  => $owner,
            group  => $group,
            mode   => '0755';
        "${status_location}/bors.css":
            owner  => $owner,
            group  => $group,
            mode   => '0644',
            source => 'puppet:///modules/bors/bors.css';
        "${status_location}/bors.html":
            owner  => $owner,
            group  => $group,
            mode   => '0644',
            source => 'puppet:///modules/bors/bors.html';
        "${status_location}/bors-render.js":
            owner   => $owner,
            group   => $group,
            mode    => '0644',
            content => template('bors/bors-render.js.erb');
        "${status_location}/dom-util.js":
            owner  => $owner,
            group  => $group,
            mode   => '0644',
            source => 'puppet:///modules/bors/dom-util.js';
    }
}
