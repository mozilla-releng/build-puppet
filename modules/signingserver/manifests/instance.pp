# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define signingserver::instance(
        $listenaddr, $port, $code_tag,
        $token_secret, $token_secret0,
        $new_token_auth, $new_token_auth0,
        $mar_key_name, $mar_sha384_key_name,
        $jar_key_name, $jar_digestalg, $jar_sigalg,
        $formats, $mac_cert_subject_ou,
        $ssl_cert, $ssl_private_key,
        $signcode_timestamp = 'yes',
        $concurrency        = 4) {
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
        "signing-${title}":
            content => "* port ${port} in ${basedir}\n",
            order   => 91;
    }

    # and that has lots of subdirectories
    $script_dir            = "${basedir}/tools/release/signing"
    $signed_dir            = "${basedir}/signed-files"
    $unsigned_dir          = "${basedir}/unsigned-files"

    $secrets_dir           = "${basedir}/secrets"
    $signcode_keydir       = "${secrets_dir}/signcode"
    $sha2signcode_keydir   = "${secrets_dir}/sha2signcode"
    $gpg_homedir           = "${secrets_dir}/gpg"
    $mar_keydir            = "${secrets_dir}/mar"
    $mar_sha384_keydir     = "${secrets_dir}/mar-sha384"
    $jar_keystore          = "${secrets_dir}/jar"
    $server_certdir        = "${secrets_dir}/server"
    $emevoucher_key        = "${secrets_dir}/emevouch.pem"
    $emevoucher_chain      = "${secrets_dir}/emechain.pem"

    $dmg_keydir            = "${secrets_dir}/dmg"
    $dmg_keychain          = "${dmg_keydir}/signing.keychain"
    $full_private_ssl_cert = "${server_certdir}/signing.server.key"
    $full_public_ssl_cert  = "${server_certdir}/signing.server.cert"
    $widevine_keydir       = "${secrets_dir}/widevine"
    $widevine_key          = "${widevine_keydir}/key.pem"
    $widevine_cert         = "${widevine_keydir}/cert.der"
    $widevine_dir          = "${basedir}/scripts"
    $widevine_signer       = "${widevine_dir}/widevine_signer.py"
    $widevine_checker      = "${widevine_dir}/widevine_checker.py"

    # paths in packages
    $signmar               = '/tools/signmar/bin/signmar'
    $signmar_sha384        = '/tools/signmar-sha384/bin/signmar'
    $testfile_dir          = '/tools/signing-test-files'
    $testfile_signcode     = "${testfile_dir}/test.exe"
    $testfile_osslsigncode = "${testfile_dir}/test64.exe"
    $testfile_emevoucher   = "${testfile_dir}/test.bin"
    $testfile_mar          = "${testfile_dir}/test.mar"
    $testfile_mar_sha384   = "${testfile_dir}/test.mar"
    $testfile_gpg          = "${testfile_dir}/test.mar"
    $testfile_dmg          = "${testfile_dir}/test.tar.gz"
    $testfile_jar          = "${testfile_dir}/test.zip"
    $testfile_widevine     = "${testfile_dir}/test.tar.gz"
    $testfile_widevine_blessed = "${testfile_dir}/test.exe"

    # commands
    $signscript            = "${basedir}/bin/python2.7 ${script_dir}/signscript.py -c ${basedir}/signscript.ini"
    $mar_cmd               = "${signmar} -d ${basedir}/secrets/mar -n ${mar_key_name} -s"
    $mar_sha384_cmd        = "${signmar_sha384} -d ${basedir}/secrets/mar-sha384 -n ${mar_sha384_key_name} -s"
    $widevine_cmd          = "${basedir}/bin/python2.7 ${widevine_dir}/widevine_signer.py --private_key %(widevine_key)s --certificate %(widevine_cert)s --input %(input)s --output_file %(output)s --flags %(blessed)s --prompt_passphrase"

    # copy vars from config
    $tools_repo            = $config::signing_tools_repo
    $mac_id                = $config::signing_mac_id
    $allowed_ips           = $config::signing_allowed_ips
    $new_token_allowed_ips = $config::signing_new_token_allowed_ips

    $user                  = $users::signer::username
    $group                 = $users::signer::group

    if ($mac_id == '') {
        fail('Config::signing_mac_id is not set')
    }

    # OS X does not yet support firewall manipulation and cannot build cryptography
    if $::operatingsystem != 'Darwin' {
        fw::port {
            "tcp/${port}": ;
        }
        # If you edit this, edit the mac virtualenv_packages below!
        $virtualenv_packages = [
            'gevent==0.13.6',
            'WebOb==1.0.8',
            'poster==0.8.1',
            'IPy==0.75',
            'greenlet==0.3.1',
            'redis==2.4.5',
            'flufl.lock==2.2',
            'pexpect==2.4',
            # widevine: osx can't build cryptography and doesn't need these!
            'argparse==1.4.0',
            'setuptools==33.1.1',
            'six==1.10.0',
            'enum34==1.1.6',
            'ipaddress==1.0.18',
            'asn1crypto==0.22.0',
            'cffi==1.10.0',
            'cryptography==2.0.2',
            'macholib==1.8',
            'altgraph==0.14',
            'idna==2.5',
            'pycparser==2.17',
            'wsgiref==0.1.2',
        ]
    } else {
        # If you edit this, edit the linux virtualenv_packages above!
        $virtualenv_packages = [
            'gevent==0.13.6',
            'WebOb==1.0.8',
            'poster==0.8.1',
            'IPy==0.75',
            'greenlet==0.3.1',
            'redis==2.4.5',
            'flufl.lock==2.2',
            'pexpect==2.4',
        ]
    }

    python::virtualenv {
        $basedir:
            python   => $packages::mozilla::python27::python,
            require  => [
                Class['packages::mozilla::python27'],
                Class['packages::libevent'],
                $signingserver::base::compiler_req, # for compiled extensions
            ],
            user     => $user,
            group    => $group,
            packages => $virtualenv_packages;
    }

    mercurial::repo {
        "signing-${title}-tools":
            require => Python::Virtualenv[$basedir],
            hg_repo => $tools_repo,
            dst_dir => "${basedir}/tools",
            user    => $user,
            rev     => $code_tag;
    }

    if $ssl_cert == '' {
        fail('missing ssl_cert')
    }
    if $ssl_private_key == '' {
        fail('missing ssl_private_key')
    }

    if $::operatingsystem == 'Darwin' {
        sudoers::custom {
            "${basedir}/tools/release/signing/signing_wrapper.sh":
                user    => $user,
                runas   => 'root',
                command => "${basedir}/tools/release/signing/signing_wrapper.sh";
        }
    }

    file {
        [ $signed_dir,
          $unsigned_dir,
          $secrets_dir,
          $signcode_keydir,
          $sha2signcode_keydir,
          $gpg_homedir,
          $mar_keydir,
          $mar_sha384_keydir,
          $dmg_keydir,
          $server_certdir,
          $widevine_keydir,
          $widevine_dir]:
            ensure  => directory,
            owner   => $user,
            group   => $group,
            require => Python::Virtualenv[$basedir];
        "${basedir}/signing.ini":
            content   => template('signingserver/signing.ini.erb'),
            owner     => $user,
            group     => $group,
            notify    => Exec["${title}-reload-signing-server"],
            require   => Python::Virtualenv[$basedir],
            show_diff => false;
        "${basedir}/signscript.ini":
            content   => template('signingserver/signscript.ini.erb'),
            owner     => $user,
            group     => $group,
            notify    => Exec["${title}-reload-signing-server"],
            require   => Python::Virtualenv[$basedir],
            show_diff => false;
        "${widevine_signer}":
            content   => secret('widevine_signer'),
            owner     => $user,
            group     => $group,
            mode      => 0755,
            show_diff => false;
        "${widevine_checker}":
            content   => secret('widevine_checker'),
            owner     => $user,
            group     => $group,
            mode      => 0755,
            show_diff => false;

        $full_private_ssl_cert:
            content   => $ssl_private_key,
            owner     => $user,
            group     => $group,
            show_diff => false,
            mode      => '0600';

        $full_public_ssl_cert:
            content => $ssl_cert,
            owner   => $user,
            group   => $group;
    }

    # The actual signing process is started by hand by users, who must then
    # enter a passphrase or two.  This script restarts it as necessary.
    exec {
        "${title}-reload-signing-server":
            command     => "${basedir}/bin/python tools/release/signing/signing-server.py -l signing.log -d signing.ini --reload",
            cwd         => $basedir,
            onlyif      => "/bin/sh -c 'test -e ${basedir}/signing.pid'",
            refreshonly => true;
    }
}
