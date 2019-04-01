# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define signingserver::instance(
        $listenaddr, $port, $code_tag,
        $token_secret, $token_secret0,
        $new_token_auth, $new_token_auth0,
        $mar_key_name, $formats, $mac_cert_subject_ou,
        $ssl_cert, $ssl_private_key,
        $signcode_timestamp = 'yes',
        $concurrency        = 4,
        # When signcode_maxsize changes, please inform
        # secops+fx-sig-verify@m.c as they have similar limit.
        $signcode_maxsize   = 416262000) {
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
    $sha2signcode_keydir   = "${secrets_dir}/sha2signcode"
    $gpg_homedir           = "${secrets_dir}/gpg"
    $mar_keydir            = "${secrets_dir}/mar"
    $server_certdir        = "${secrets_dir}/server"

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
    $testfile_dir          = '/tools/signing-test-files'
    $testfile_mar          = "${testfile_dir}/test.mar"
    $testfile_gpg          = "${testfile_dir}/test.mar"
    $testfile_dmg          = "${testfile_dir}/test.tar.gz"
    $testfile_widevine     = "${testfile_dir}/test.tar.gz"
    $testfile_widevine_blessed = "${testfile_dir}/test.exe"

    # commands
    $signscript            = "${basedir}/bin/python2.7 ${script_dir}/signscript.py -c ${basedir}/signscript.ini"
    $mar_cmd               = "${signmar} -d ${basedir}/secrets/mar -n ${mar_key_name} -s"
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

    # OSX cannot build cryptography
    if $::operatingsystem != 'Darwin' {
        $virtualenv_packages = file("signingserver/linux_requirements.txt")
    } else {
        $virtualenv_packages = file("signingserver/mac_requirements.txt")
    }

    python::virtualenv {
        $basedir:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => [
                Class['packages::mozilla::python27'],
                Class['packages::libevent'],
                $signingserver::base::compiler_req, # for compiled extensions
            ],
            user            => $user,
            group           => $group,
            packages        => $virtualenv_packages;
    }

    # system hg is broken on mac signing servers =\
    # a human should clone using the venv's bin/hg
    if $::operatingsystem != 'Darwin' {
        mercurial::repo {
            "signing-${title}-tools":
                require => Python::Virtualenv[$basedir],
                hg_repo => $tools_repo,
                dst_dir => "${basedir}/tools",
                user    => $user,
                rev     => $code_tag;
        }
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
          $sha2signcode_keydir,
          $gpg_homedir,
          $mar_keydir,
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
