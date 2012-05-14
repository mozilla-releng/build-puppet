# virtual resources that are realized in the toplevel classes where they're used
class nrpe::checks {
    include nrpe::settings
    include nrpe::base

    $plugins_dir = $nrpe::settings::plugins_dir

    @nrpe::check {
        'check_buildbot':
            cfg => $operatingsystem ? {
                CentOS => "$plugins_dir/check_procs -w 1:1 -C twistd --argument-array=buildbot.tac",
                Darwin => "$plugins_dir/check_procs -w 1:1 -C python --argument-array=buildbot.tac",
            };
        'check_ide_smart':
            cfg => "sudo $plugins_dir/check_ide_smart -n -d \$ARG1\$";
        'check_procs_regex':
            cfg => "$plugins_dir/check_procs -c \$ARG2\$:\$ARG3\$ --ereg-argument-array=\$ARG1\$";
        'check_child_procs_regex':
            cfg => "$plugins_dir/check_procs -c \$ARG3\$:\$ARG4\$ --ereg-argument-array=\$ARG1\$ -p \$ARG2\$";
        'check_swap':
            cfg => "$plugins_dir/check_swap -w \$ARG1\$ -c \$ARG2\$";
#        'check_mysql':
#            cfg => "/usr/<%=libdir%>/nagios/plugins/check_mysql -H <%= scope.lookupvar('secrets::buildbot_schedulerdb_host') %> -u <%= scope.lookupvar('secrets::buildbot_schedulerdb_user') %> -p <%= scope.lookupvar('secrets::buildbot_schedulerdb_password') %>";
        'check_ntp_time':
            cfg => "$plugins_dir/check_ntp_time -H \$ARG1\$ -w \$ARG2\$ -c \$ARG3\$";
        'check_http_redirect_ip':
            cfg => "$plugins_dir/check_http_redirect_ip -U \$ARG1\$ -I \$ARG2\$",
            plugin => "check_http_redirect_ip";
        'check_ganglia':
            cfg => "$plugins_dir/check_ganglia -h \$ARG1\$ -s \$ARG2\$ -m \$ARG3\$ -w \$ARG4\$ -c \$ARG5\$",
            plugin => "check_ganglia";
    }
}

