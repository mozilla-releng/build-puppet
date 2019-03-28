# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define scriptworker::chain_of_trust(
  $basedir,
  $ed25519_privkey,
  $username,
) {
  file {
    "${basedir}/gpg_key_repo":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true;
    "/home/${username}/.gnupg":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true;
    "${basedir}/git_pubkeys":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true;
    '/etc/cron.d/scriptworker':
        ensure => absent;
    "${basedir}/.git-pubkey-dir-checksum":
        ensure => absent;
    "/home/${username}/pubkey":
        ensure => absent;
    "/home/${username}/privkey":
        ensure => absent;
    "${basedir}/bin/rebuild_gpg_homedirs":
        ensure => absent;
  }

  file {
    "/home/${username}/ed25519_privkey":
        ensure    => present,
        content   => $ed25519_privkey,
        mode      => '0600',
        owner     => $username,
        group     => $group,
        show_diff => false;
  }
}
