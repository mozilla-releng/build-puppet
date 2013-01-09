# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::check::ganglia {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    # TODO: the secrets here don't exist yet.  To fix when we set up masters.
    nrpe::check {
        'check_mysql':
            cfg => "/usr/<%=libdir%>/nagios/plugins/check_mysql -H <%= scope.lookupvar('secrets::buildbot_schedulerdb_host') %> -u <%= scope.lookupvar('secrets::buildbot_schedulerdb_user') %> -p <%= scope.lookupvar('secrets::buildbot_schedulerdb_password') %>";
    }
}
