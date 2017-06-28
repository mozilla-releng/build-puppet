# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All nodes should include a subclass of this class.  It sets up global
# parameters that apply to all releng hosts.

class toplevel::jumphost {
    # as good a place as any.. let's make sure this host's certname maches its
    # fqdn, as otherwise bad things happen.  Note that this is *not* a security
    # measure!  That's performed by puppet itself, based on nodename = cert
    if ($::fqdn != $::clientcert) {
        fail("This host's fqdn fact, '${::fqdn}', does not match its clientcert fact, '${::clientcert}'.  This will lead to sadness!")
    }

    # Manage this in the packagesetup stage so that they are in place by the
    # time any Package resources are managed.
    class {
        'packages::setup': stage => packagesetup,
    }

    include ::config

    include puppet
    include network
    include hardware
    include timezone
    include powermanagement
    include ssh
    include collectd
    include ntp::daemon
    include smarthost
    include cron
    include disableservices::server

    include duo

    include users::root
    include sudoers
    include users::global
    include users::people

    include nrpe
    include nrpe::check::ntp_time
    include nrpe::check::ntp_peer
    include nrpe::check::procs_regex
    include nrpe::check::child_procs_regex
    include nrpe::check::swap
    include nrpe::check::ide_smart
    include nrpe::check::puppet_freshness

    include security::motd

    include tweaks::tcp_challenge_ack_limit
    include tweaks::rc_local
    include needs_reboot
    include log_aggregator::client

    include packages::kernel
    include packages::openssl
    include packages::libc
    include packages::bash
    include packages::editors
    include packages::screen
    include packages::strace
    include packages::netcat
    include packages::security_updates

    class { 'auditd': host_type => 'server' }
    include packages::procmail
    include packages::nslookup
    include packages::nss_tools
    include packages::snmp
    include packages::wget
    include packages::mysql_devel
    include packages::subversion

    class { 'web_proxy':
        host       => $::config::web_proxy_host,
        port       => $::config::web_proxy_port,
        exceptions => $::config::web_proxy_exceptions
    }

    if ($::config::enable_mig_agent) {
        include mig::agent::daemon
    }
}
