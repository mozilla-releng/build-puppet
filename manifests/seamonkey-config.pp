# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# We use config rather than settings because "settings" is a magic class
class config inherits config::base {
    $org = "seamonkey"

    $manage_ifcfg = false # SeaMonkey expects to set IP/gateway manually

    $puppet_notif_email = "seamonkey-release@mozilla.org"
    $builder_username = "seabld"

    $puppet_servers = [
        "sea-puppet.community.scl3.mozilla.com"
    ]
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server

    $distinguished_puppetmaster = "sea-puppet.community.scl3.mozilla.com"
    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet/"
    $puppetmaster_extsyncs = {
        'fake_slavealloc' => {
            # No real slavealloc to use, so do this manually
        },
        'moco_ldap' => {
            'moco_ldap_uri' => 'ldaps://ldap.mozilla.org/',
            'moco_ldap_root' => 'dc=mozilla',
            'moco_ldap_dn' => secret('moco_ldap_dn'),
            'moco_ldap_pass' => secret('moco_ldap_pass'),
            'users_in_groups' => {
                'ldap_admin_users' => [
                    'netops', 'team_dcops', 'team_opsec', 'team_moc', 'team_infra', 'team_storage'],
            },
        }
    }

    # pending setting up LDAP sync or some other similar tool for seamonkey
    $extra_user_ssh_keys = {
        'dmitchell' => ['ssh-dss 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 dustin-passphrase'],
        'ewong' => ['ssh-dss AAAAB3NzaC1kc3MAAACBAPddjaJd/geESZNI/2usKBb9jpP92B0pCWz7lslfXUpr9u07fW1w9TS5OEXYiw1fd704SiONpE7a/Y3zs9b7gm+CHE+zwuHulh47lUf3K0VvB3LwDxz4hYEk/mo1kv8MsKaQd69vRilbNtS3/tpzuRnCJ0yczmuy4IxonhDcj6kzAAAAFQCBw/3o4eXDOhg7ijERjV2LQ9b/TwAAAIEAg2CyV1YWLpzKFKUZ9Ulb3u3kV5X9PEAhIpkb3/JBbkAMD0EJymqIE2FX+N4GMJHWwtRqhdEXXmTjDfSA6kkeva8vHFd39ocDB/KbZK8sTKDdc+Puxms+sMZua6vRySzSE2iHRiD5ioRCH3T/k2rimcWGQ01NTKxgRPVZAtAOmEQAAACAFfwIE1agGmMdTLmB6kGVVWW1ImlnwbM86kPTggHv2PtN+KP7AFfXkhYyPqPHEgXUcHcjLEz7bVyo9W7DG97NgY3g5Af1Y5TH7XTLsj9qY3J5OvwGxBb2x/0QEalyvjTRBdPzX5hOI4A8uxuBVGNj93/RVLp0WIWlAYEwXfg7HLU= cc@IT'],
        'jwood' => ['ssh-dss AAAAB3NzaC1kc3MAAACBANIpiPPiAWxWx/Syoj6NzVuqL1OCp1pWJ/7lAq4zV6pKdDSKxic4fwcvYi81/bYJnhy9RId+R4uBZUMzl7n3ZICBa+6ojYQ2ieosho9yneI/zyAmutiPa88qQoczMB2EJ3iCsmm5MjGX1AiDsvy42EKguuOL3f9i8TRNMjGkjg3XAAAAFQDntoz8Vzn+0eb3RuS3gl+rYzJOoQAAAIA5m1g21C4XfBKt+zgsGP7tQTckQEPa7WdxBRoiClYt8RCcYKa3AqYSQj+4zkHKCfsPQQ9U9wuWrJLFn79U9OtA/5C92WKqa7CgiWRZzCc/xyPju7c0Tl2siqus/zvrz8eyNQxDkHMAEJE6t4MpzxX3ZwVjH44q3M65AtLSuNtVqAAAAIEAgT4SjEwRASz1/DsoOejgH+Mqm8SA2WqvsD+P86MrtuvemlsuLyPk8dqN3IWl+9cukhr/A1BflTlDhIKJirHZyPbB2d79WiHwVI+0ZgrhVCL2kBPdRapiHRicOMZNrDPDRofUsga+fpN0MDbrEX7vMnxflvmD6az7wZrFqkYx4As= Programming@DELLXPS400-1', 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApTbndiZFtSSYvV7DgG7RTAFnojb7Yy7NPSsuH2PJffQ6u5+6u6+yg3SAH9ldqV0dt+oEaYRRscRO/pbuX9HMDnOzMae+WE1llILDQKo27K1B//Dd+9SGdEzNV1+PTuPcuwWKZ9mnA6hWlEshxxVZEbShSB+3yYOB4sx3Lzah7DRXsM/fSOW12oJ0bGHah7Tyegs5mrq2SWrLa4P8Ja3Ord2r2RqH68aePkYuD4TFKN5rTIlgLB1OMJaAwvq67791D168X861r1elELYiwhk/hUCXwRrXh0d2JuHM0kVRa6jJZnwd1zbiNGUcxv4a2iP9CD+5ii6fvop1ysuIcBl9Lw== Callek'],
        'kairo' => ['ssh-dss AAAAB3NzaC1kc3MAAACBAIk7nr9g/bC+h6L0P7C11WehkRp+Dl9wgCeSoX8kYHQo4e7F3cq6oD/rZ11ROHw9+hOUc5kCKDaYxOUzNd4RP9V8zUl5pDzkhUJNABskRa215rkFGSdSjIBiKy4UaM0sO0JCS+L5g0A0SWr5aOynheRY8n0pCauDQuFCkx9S+eibAAAAFQD/3jofIyYBxv9+uhVW6PcHiaGKnQAAAIB3Pto6pKDvdJWe2l6aZEGM+H3TveI5C99QB6296H+2i4FvqnhLwze9KoXb1leHXR7rGtd8UJdKdBx1hFhNMhoknWpIw0zDDpR8cfk48aDuN2MD6yuVJcv9ZiYDK3DUq4UaKSQForjCDwvJjIsUiWD9pxZsB/m8Q4/Q7o/i2Jq3vAAAAIAdlf1AVlhLhZQkMq9pRNjAgs4+lwhAdbv7j9e5q50XAVXWIVvo9EBXTo87nQJE1dJN9TsFdVotT7vuhsy47Z9eghTYLfYuOtkaR2MXuy6hnq3Hdh8BZpR9OTzzxZX5qQETI6s83tSWuDoomVz6HRN1H00rxBMKKvylu0FO4JW+FQ== robert@robert'],
    }

    $admin_users = [
        # TODO: use unique(concat(..)) to concatenate the SM admins with a list of infra people
        "dmitchell",
        "ewong",
        "jwood",
        "kairo",
        "jdow",
    ]
    $master_json = "https://hg.mozilla.org/users/Callek_gmail.com/tools/raw-file/default/buildfarm/maintenance/sea-production-masters.json"
    $buildbot_tools_hg_repo = "https://hg.mozilla.org/users/Callek_gmail.com/tools/"
    $buildbot_configs_hg_repo = "https://hg.mozilla.org/build/buildbot-configs"
    $buildbot_configs_branch = "seamonkey-production"
    $buildbotcustom_branch = "seamonkey-production"
    $buildbot_mail_to = "seamonkey-release@mozilla.org"

    $buildmaster_ssh_keys = ['seabld_dsa', 'id_dsa']

    # runner task settings
    $runner_hg_tools_path = '/tools/checkouts/build-tools'
    $runner_hg_tools_repo = 'https://hg.mozilla.org/users/Callek_gmail.com/tools/'
    $runner_hg_tools_branch = 'default'
    $runner_hg_mozharness_path = '/tools/checkouts/mozharness'
    $runner_hg_mozharness_repo = 'https://hg.mozilla.org/build/mozharness'
    $runner_hg_mozharness_branch = 'production'
    $runner_env_hg_share_base_dir = '/builds/hg-shared'
    $runner_env_git_share_base_dir = '/builds/git-shared'
    $runner_buildbot_slave_dir = '/builds/slave'
}
