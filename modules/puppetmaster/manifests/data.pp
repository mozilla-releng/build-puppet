# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::data {
    include puppetmaster::settings
    include packages::createrepo
    include packages::debmirror
    include packages::hardlink

    # invent a random time for this host to synchronize.  Cron doesn't like
    # minutes written as "*/0,30", so this runs from 1..29
    $minute     = fqdn_rand(29)+1
    $minuteplus = $minute + 30
    $minutes    = "${minute},${minuteplus}"

    if ($puppetmaster::settings::is_distinguished) {
        file {
            # the distinguished master fixes its permissions periodically (to make sure
            # everything is owned by the puppetsync user)
            '/usr/local/sbin/puppetmaster-fixperms':
                mode    => '0755',
                content => template("${module_name}/puppetmaster-fixperms.erb");
            '/etc/cron.d/puppetmaster-fixperms':
                content => "*/30 * * * * root /usr/local/sbin/puppetmaster-fixperms\n";
            # .. and does not sync from other masters
            '/etc/cron.d/puppetmaster-sync':
                ensure => absent;
        }
        motd {
            'puppetmaster-sync':
                content => "** This is the distinguished master; other masters copy /data from here.\n";
        }
    } else {
        file {
            # a non-DM syncs from the DM
            '/usr/local/sbin/puppetmaster-sync':
                mode    => '0755',
                content => template("${module_name}/puppetmaster-sync.erb");
            '/etc/cron.d/puppetmaster-sync':
                content => "${minutes} * * * * root /usr/local/sbin/puppetmaster-sync\n";
            # .. and does not fix permissions
            '/etc/cron.d/puppetmaster-fixperms':
                ensure => absent;
        }
        motd {
            'puppetmaster-sync':
                content => "** This master copies its /data from ${puppetmaster::settings::distinguished_master} at ${minute} past the half-hour\n** Run puppetmaster-sync to synchronize this host now.\n";
        }
    }

    # debmirror needs some configuration

    file {
        # clear out the tool's default config, which otherwise automatically mirrors sid
        '/etc/debmirror.conf':
            require => Class['packages::debmirror'],
            content => '1;';
        '/etc/debmirror-gpg':
            ensure => directory,
            mode   => '0600';
        '/etc/debmirror-gpg/40976eaf437d05b5.gpg':
            source => "puppet:///modules/${module_name}/40976eaf437d05b5.gpg";
    }

    exec {
        'debmirror-get-key':
            command     => '/usr/bin/gpg --no-default-keyring --keyring /etc/debmirror-gpg/trustedkeys.gpg  --import /etc/debmirror-gpg/40976eaf437d05b5.gpg',
            environment => [ 'GNUPGHOME=/etc/debmirror-gpg' ],
            creates     => '/etc/debmirror-gpg/trustedkeys.gpg',
            require     => File['/etc/debmirror-gpg/40976eaf437d05b5.gpg'];
    }

    # handle upstream synchronization on the DM
    $crontab = '/etc/cron.d/puppetmaster-upstream-rsync'
    $script  = '/etc/puppet/puppetmaster-upstream-rsync.sh'
    if ($puppetmaster::settings::is_distinguished and $puppetmaster::settings::upstream_rsync_source != '') {
        $upstream_minute = ($minute + 15) # (minute < 30, so this is OK)
        file {
            $crontab:
                content => "${upstream_minute} * * * * root ${script}\n";
            $script:
                mode    => '0755',
                content => template("${module_name}/puppetmaster-upstream-rsync.sh.erb");
        }
    } else {
        file {
            [ $crontab, $script ]:
                ensure => absent;
        }
    }
}
