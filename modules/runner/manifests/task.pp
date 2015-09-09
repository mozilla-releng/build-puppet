# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# a task to be run by runner
define runner::task($content=undef, $source=undef) {
    include runner::settings

    $runner_service = $operatingsystem ? {
        Windows => Exec['startrunner'],
        default => Service['runner'],
    }
     $mode  = $operatingsystem ? {
        Windows => undef,
        default => '0755',
    }

    file {
        "${runner::settings::taskdir}/${title}":
            before  => $runner_service,
            content => $content,
            source  => $source,
            mode    => $mode;
    }
    if ($::operatingsystem == Windows) {
        acl {
            "${runner::settings::taskdir}/${title}":
                purge => true,
                inherit_parent_permissions => false,
                permissions => [
                    { identity => 'root', rights => ['full'] },
                    { identity => 'cltbld', rights => ['full'] },
                    { identity => 'SYSTEM', rights => ['full'] },
                    { identity => 'EVERYONE', rights => ['read'] },
                ];
        }
    }
}
