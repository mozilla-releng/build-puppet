# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# All TaskCluster workers are subclasses of this class.

class toplevel::worker inherits toplevel::base {
    include ::config
    include ::generic_worker
    include disableservices::slave
    include puppet::atboot
    include sudoers::reboot
    include users::builder
    include python::system_pip_conf

    if ($::operatingsystem == 'Darwin') or ($::operatingsystem == 'Ubuntu') {
        # roller user ssh
        include users::roller
    }

    $group = $::operatingsystem ? {
        Darwin  => 'staff',
        default => undef,
    }

    class { 'telegraf':
        interval       => '60s',
        flush_interval => '600s',
        hostname => regsubst($::fqdn, '([^\.]+)\..*', '\1'),
        config_file_group => $group,

        global_tags    => {
            'fqdn'        => $::fqdn,
            'workerType'  => $generic_worker::worker_type,
            'workerGroup' => $generic_worker::worker_group,
            'dataCenter'  => regsubst($::fqdn, '.*\.releng\.(.+)\.mozilla\..*', '\1'),
        },
        outputs        => {
            'influxdb' => {
                'urls'     => [ $::config::telegraf_host ],
                'database' => $::config::telegraf_db,
                'username' => $::config::telegraf_user,
                'password' => $::config::telegraf_password,
                'skip_database_creation' => true,
            }
        },
        inputs => {
        },
    }

    telegraf::input { 'puppet-agent':
        plugin_type => 'puppetagent',
    }

    telegraf::input { 'procstat':
        plugin_type => 'procstat',
        options => {
          'exe' => 'generic-worker',
        },
    }

    telegraf::input { 'logparser':
        plugin_type => 'logparser',
        options => {
          'files' => [ '~cltbld/tasks/task*/logs/*error.log' ],
          'from_beginning' => false,
        },
        single_section => {
          'logparser.grok' => {
            'timezone' => 'Local',
            'patterns' => [ '%{TIME}%{SPACE}%{LOGLEVEL} - The %{NOTSPACE:group:tag} suite: %{NOTSPACE:name:tag} %{GREEDYDATA:message}',
                            '%{TIME}%{SPACE}%{LOGLEVEL} - %{NOTSPACE:exception:tag}E[roxceptin]*: %{GREEDYDATA:message}',
                            '\[([^:]*): %{TIMESTAMP_ISO8601:timestamp:ts-"2006-01-02 15:04:05.000000Z07:00"}\] %{WORD:state} %{GREEDYDATA:step} step(\.| \(%{WORD:result}\))',
            ]
          },
        },
    }

    # validate apple firmware versions
    include hardware::apple_firmware

    # apply tweaks
    include tweaks::dev_ptmx
    include tweaks::locale

    # common packages
    include packages::curl
    include packages::virtualenv

    # *all* Darwin and Windows workers need to autologin, not just testers
    if ($::operatingsystem == 'Darwin') or ($::operatingsystem == 'Windows') {
        include users::builder::autologin
    }
}
