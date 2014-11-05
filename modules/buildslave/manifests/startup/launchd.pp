# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildslave::startup::launchd {
    # on macs, there are a few wrinkles:
    #
    # 1. Buildslave must run in the user context, so it can have access to the
    # GUI and other user-like things.  Simply running as the builder user is
    # not sufficient.
    #
    # 2. Launchd does not support any kind of dependencies between services, so
    # there is no "normal" way to ensure that buildslave starts only after
    # puppet has run.
    #
    # The approach taken here is to add a launch agent (runs as any logged-in
    # user) which is only started when a semaphore file exists (using
    # KeepAlive:PathState).  This file is level-triggered (meaning that buildbot
    # will start if the file exists, not just when it is touched), so there is
    # no race condition.
    #
    # The run-puppet.sh script used to run puppet on macs touches this file
    # when it has successfully invoked puppet.

    $buildslave_path = "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin"

    file {
        "/Library/LaunchAgents/com.mozilla.buildslave.plist":
            owner => root,
            group => wheel,
            mode => 0644,
            content => template("buildslave/buildslave.plist.erb");

        "/usr/local/bin/run-buildslave.sh":
            source => "puppet:///modules/${module_name}/darwin-run-buildslave.sh",
            mode => 0755;
    }
}
