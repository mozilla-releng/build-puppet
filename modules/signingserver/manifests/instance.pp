# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define signingserver::instance(
        $listenaddr, $port, $code_tag,
        $token_secret, $token_secret0,
        $new_token_auth, $new_token_auth0,
        $mar_key_name, $jar_key_name,
        $b2g_key0, $b2g_key1, $b2g_key2,
        $formats, $mac_cert_subject_ou,
        $signcode_timestamp="yes",
        $concurrency=4) {
    include config
    include signingserver::base
    include users::signer

    # verify non-empty secrets first
    if ($token_secret == '') { fail('token_secret is empty') }
    if ($token_secret0 == '') { fail('token_secret0 is empty') }
    if ($new_token_auth == '') { fail('new_token_auth is empty') }
    if ($new_token_auth0 == '') { fail('new_token_auth0 is empty') }

    $basedir = "${signingserver::base::root}/${title}"

    motd {
        "signing-$title":
            content => "* port ${port} in ${basedir}\n",
            order => 91;
    }

    # and that has lots of subdirectories
    $script_dir = "${basedir}/tools/release/signing"
    $signed_dir = "${basedir}/signed-files"
    $unsigned_dir = "${basedir}/unsigned-files"

    $secrets_dir = "${basedir}/secrets"
    $signcode_keydir = "${secrets_dir}/signcode"
    $gpg_homedir = "${secrets_dir}/gpg"
    $mar_keydir = "${secrets_dir}/mar"
    $jar_keystore = "${secrets_dir}/jar"
    $server_certdir = "${secrets_dir}/server"
    $emevoucher_key = "${secrets_dir}/emevouch.pem"
    $emevoucher_chain = "${secrets_dir}/emechain.pem"

    $dmg_keydir = "${secrets_dir}/dmg"
    $dmg_keychain = "${dmg_keydir}/signing.keychain"
    $full_private_ssl_cert = "${server_certdir}/signing.server.key"
    $full_public_ssl_cert = "${server_certdir}/signing.server.cert"

    # paths in packages
    $signmar = "/tools/signmar/bin/signmar"
    $testfile_dir = "/tools/signing-test-files"
    $testfile_signcode = "${testfile_dir}/test.exe"
    $testfile_osslsigncode = "${testfile_dir}/test64.exe"
    $testfile_emevoucher = "${testfile_dir}/test.bin"
    $testfile_mar = "${testfile_dir}/test.mar"
    $testfile_gpg = "${testfile_dir}/test.mar"
    $testfile_dmg = "${testfile_dir}/test.tar.gz"
    $testfile_jar = "${testfile_dir}/test.zip"

    # commands
    $signscript = "${basedir}/bin/python2.7 ${script_dir}/signscript.py -c ${basedir}/signscript.ini"
    $mar_cmd = "${signmar} -d ${basedir}/secrets/mar -n ${mar_key_name} -s"
    $b2gmar_cmd = "${signmar} -d ${basedir}/secrets/b2gmar -n0 ${b2g_key0} -n1 ${b2g_key1} -n2 ${b2g_key2} -s"

    # copy vars from config
    $tools_repo = $config::signing_tools_repo
    $mac_id = $config::signing_mac_id
    $allowed_ips = $config::signing_allowed_ips
    $new_token_allowed_ips = $config::signing_new_token_allowed_ips

    $user = $users::signer::username
    $group = $users::signer::group

    if ($mac_id == '') {
        fail("config::signing_mac_id is not set")
    }

    # OS X does not yet support firewall manipulation
    if $::operatingsystem != 'Darwin' {
        fw::port {
            "tcp/$port": ;
        }
    }

    python::virtualenv {
        $basedir:
            python => $packages::mozilla::python27::python,
            require => [
                Class['packages::mozilla::python27'],
                Class['packages::libevent'],
                $signingserver::base::compiler_req, # for compiled extensions
            ],
            user => $user,
            group => $group,
            packages => [
                'gevent==0.13.6',
                'WebOb==1.0.8',
                'poster==0.8.1',
                'IPy==0.75',
                'greenlet==0.3.1',
                'redis==2.4.5',
                'flufl.lock==2.2',
                'pexpect==2.4',
            ];
    }

    mercurial::repo {
        "signing-${title}-tools":
            require => Python::Virtualenv[$basedir],
            hg_repo => $tools_repo,
            dst_dir => "${basedir}/tools",
            user => $user,
            rev => $code_tag;
    }

    file {
        [$signed_dir,
         $unsigned_dir,
         $secrets_dir,
         $signcode_keydir,
         $gpg_homedir,
         $mar_keydir,
         $dmg_keydir,
         $server_certdir]:
            ensure => directory,
            owner => $user,
            group => $group,
            require => Python::Virtualenv[$basedir];
        "${basedir}/signing.ini":
            content => template("signingserver/signing.ini.erb"),
            owner => $user,
            group => $group,
            notify => Exec["$title-reload-signing-server"],
            require => Python::Virtualenv[$basedir],
            show_diff => false;
        "${basedir}/signscript.ini":
            content => template("signingserver/signscript.ini.erb"),
            owner => $user,
            group => $group,
            notify => Exec["$title-reload-signing-server"],
            require => Python::Virtualenv[$basedir],
            show_diff => false;
# TODO
#        $full_private_ssl_cert:
#            content => file("/etc/puppet/secrets/signing.server.key"),
#            mode => 600;
        $full_public_ssl_cert:
            owner => $user,
            group => $group,
            source => "puppet:///modules/signingserver/${config::org}/signing.server.cert";
    }

    # The actual signing process is started by hand by users, who must then
    # enter a passphrase or two.  This script restarts it as necessary.
    exec {
        "$title-reload-signing-server":
            command => "${basedir}/bin/python tools/release/signing/signing-server.py -l signing.log -d signing.ini --reload",
            cwd => $basedir,
            onlyif => "/bin/sh -c 'test -e ${basedir}/signing.pid'",
            refreshonly => true;
    }
}
