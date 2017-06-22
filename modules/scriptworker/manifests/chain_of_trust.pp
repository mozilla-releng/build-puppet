# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define scriptworker::chain_of_trust(
  $basedir,

  $git_key_repo_dir,
  $git_key_repo_url,
  $git_pubkey_dir,

  $pubkey,
  $privkey,

  $username,
) {
  # This git repo has the various worker pubkeys
  git::repo {
      "scriptworker-${git_key_repo_dir}":
          repo    => $git_key_repo_url,
          dst_dir => $git_key_repo_dir,
          user    => $username,
          require => Python35::Virtualenv[$basedir];
  }

  File {
    ensure      => present,
    mode        => '0600',
    owner       => $username,
    group       => $group,
    show_diff   => false,
  }

  file {
    # $username's gpg homedir: for git commit signature verification
    "/home/${username}/.gnupg":
        ensure      => directory;
    # these are the pubkeys that can sign git commits
    $git_pubkey_dir:
        ensure       => directory,
        source       => 'puppet:///modules/scriptworker/git_pubkeys',
        recurse      => true,
        recurselimit => 1,
        purge        => true,
        require      => Python35::Virtualenv[$basedir];
    # cron jobs to poll git + rebuild gpg homedirs
    '/etc/cron.d/scriptworker':
        content     => template('scriptworker/scriptworker.cron.erb');
    # Notify rebuild_gpg_homedirs if the pubkey dir changes
    "${basedir}/.git-pubkey-dir-checksum":
        notify  => Exec['rebuild_gpg_homedirs'];
    "/home/${username}/pubkey":
        mode      => '0644',
        content   => $pubkey,
        show_diff => true;
    "/home/${username}/privkey":
        content => $privkey;
  }

  exec {
      # create gpg homedirs on change
      'rebuild_gpg_homedirs':
          require   => [Python35::Virtualenv[$basedir],
                      Git::Repo["scriptworker-${git_key_repo_dir}"],
                      File["${basedir}/scriptworker.yaml"]],
          command   => "${basedir}/bin/rebuild_gpg_homedirs ${basedir}/scriptworker.yaml",
          subscribe => File[$git_pubkey_dir],
          user      => $username;
      # Create checksum file of git pubkeys
      "${basedir}/.git-pubkey-dir-checksum":
          require => File[$git_pubkey_dir],
          path    => '/usr/local/bin/:/bin:/usr/sbin:/usr/bin',
          user    => $username,
          command => "find ${git_pubkey_dir} -type f | xargs md5sum | sort > ${basedir}/.git-pubkey-dir-checksum";
  }
}
