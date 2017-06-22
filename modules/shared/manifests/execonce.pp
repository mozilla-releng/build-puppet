# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define shared::execonce(
  $command,
  $cwd         = undef,
  $environment = undef,
  $group       = undef,
  $logoutput   = undef,
  $onlyif      = undef,
  $path        = undef,
  $provider    = undef,
  $refresh     = undef,
  $refreshonly = undef,
  $returns     = undef,
  $timeout     = undef,
  $tries       = undef,
  $try_sleep   = undef,
  $umask       = undef,
  $unless      = undef,
  $user        = undef,
) {
    include shared::execonce::base
    $semaphore = "${shared::execonce::base::semaphore_dir}/${title}.semaphore"

    exec {
        $title:
            command     => $command,
            cwd         => $cwd,
            environment => $environment,
            group       => $group,
            logoutput   => $logoutput,
            onlyif      => $onlyif,
            path        => $path,
            provider    => $provider,
            refresh     => $refresh,
            refreshonly => $refreshonly,
            returns     => $returns,
            timeout     => $timeout,
            tries       => $tries,
            try_sleep   => $try__sleep,
            umask       => $umask,
            unless      => $unless,
            user        => $user,
            creates     => $semaphore;
    }

    file {
        $semaphore:
            ensure  => present,
            require => Exec[$title];
    }
}
