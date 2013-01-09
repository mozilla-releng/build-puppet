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
    # user) which is only started when /var/tmp/puppet.finished is touched.
    # The run-puppet.sh script used to run puppet on macs touches this file
    # when it has successfully invoked puppet.
    #
    # There is a race condition here: if the buildslave launchd script has not
    # been loaded when the puppet run finishes and the file is touched, then
    # buildslave will never be triggered.  This system has worked well in
    # practice, though, so perhaps this race condition is never triggered.
    
    $buildslave_path = "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin"
                        
    file {
        "/Library/LaunchAgents/com.mozilla.buildslave.plist":
            owner => root,
            group => wheel,
            mode => 0644,
            content => template("buildslave/buildslave.plist.erb");

    }
}
