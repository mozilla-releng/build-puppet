# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class users::homeclean {
    include ::config
    include dirs::usr::local::bin

    # this script runs nightly, and cleans homedirs belonging to users who are
    # no longer in the password database.  The idea is to remove un-owned data
    # in case it is sensitive, and to prevent newly-added users from getting
    # the same userid as a previously-deleted user, which might cause
    # undesirable access to data.

    $homebase = $::operatingsystem ? {
        Darwin => '/Users',
        default => '/home'
    }

    file {
        "${homebase}/archive":
            ensure => directory,
            owner  => root,
            mode   => '0700';

        '/usr/local/bin/homeclean.sh':
            mode    => '0755',
            content => template("${module_name}/homeclean.sh.erb");
    }

    cron {
        'homeclean':
            user        => root,
            command     => '/usr/local/bin/homeclean.sh 2>&1 | logger -t homeclean.sh',
            hour        => 3,
            minute      => 0,
            environment => "MAILTO=${::config::puppet_notif_email}";
    }
}
