# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All nodes should include a subclass of this class.  It sets up global
# parameters that apply to all releng hosts.

class toplevel::base {
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

    include puppet
    include users::root
    include network
    include sudoers
    include hardware
    include ssh
    include timezone
    include tweaks::rc_local
    include needs_reboot
    include log_aggregator::client
    include packages::bash

    class { 'web_proxy':
        host       => $::config::web_proxy_host,
        port       => $::config::web_proxy_port,
        exceptions => $::config::web_proxy_exceptions
    }

    if ($::operatingsystem != Windows) {
        include packages::editors
        include packages::screen
        include users::global
        include powermanagement
        include collectd

        # openssl ends up getting pulled in as a dependency everywhere, and we
        # want to carefully control its version, so include it everywhere.
        include packages::openssl

        # ensure the version of libc where required
        include packages::libc
    }

    if $::kernel == Linux {
        include packages::kernel
        include tweaks::tcp_challenge_ack_limit
    }

    # run RDP on all windows systems
    if ($::operatingsystem == windows) {
        include rdp
        include metcollect
    }

    include security::motd
}

