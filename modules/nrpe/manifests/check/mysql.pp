class nrpe::check::ganglia {
    include nrpe::settings
    $plugins_dir = $nrpe::settings::plugins_dir

    # TODO: the secrets here don't exist yet.  To fix when we set up masters.
    nrpe::check {
        'check_mysql':
            cfg => "/usr/<%=libdir%>/nagios/plugins/check_mysql -H <%= scope.lookupvar('secrets::buildbot_schedulerdb_host') %> -u <%= scope.lookupvar('secrets::buildbot_schedulerdb_user') %> -p <%= scope.lookupvar('secrets::buildbot_schedulerdb_password') %>";
    }
}
