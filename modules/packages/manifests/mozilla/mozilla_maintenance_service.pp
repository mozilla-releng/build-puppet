# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::mozilla_maintenance_service {

    include dirs::etc::mozilla_maintenance_service

    $cert_dir = 'c:/etc/mozilla_maintenance_service'

    # Variables for reg file template
    $service_reg_path = 'HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\MaintenanceService\3932ecacee736d366d6436db0f55bce4'
    $key_0            = "${service_reg_path}\\0"
    $key_1            = "${service_reg_path}\\1"
    $key_2            = "${service_reg_path}\\2"
    $key_3            = "${service_reg_path}\\3"
    $_name            = '"name"="Mozilla Corporation"'
    $_name3           = '"name"="Mozilla Fake SPC"'
    $issuer_0         = '"issuer"="Thawte Code Signing CA - G2"'
    $issuer_1         = '"issuer"="Mozilla Fake CA"'
    $issuer_2         = '"issuer"="DigiCert SHA2 Assured ID Code Signing CA"'
    $issuer_3         = '"issuer"="Mozilla Fake CA"'
    $programname      = '"programName"=""'
    $publisherlink    = '"publisherLink"=""'

    # Original source http://runtime-binaris.pvt.build.mozilla.org
    packages::pkgzip {
        "updateservice":
            zip        => 'updateservice.zip',
            target_dir => "C:\\etc";
    }

    # After the packages is unzipped the service needs to be installed
    # The services needs to be installed but not necessarily running
    # Hence no attempt to use the service resource to manage it

    exec {
        'install_moz_maintce_serv':
            command     => "C:\\etc\\maintenanceservice_installer.exe",
            subscribe   => Packages::Pkgzip['updateservice'],
            refreshonly => true;
    }
    # Reference https://bugzilla.mozilla.org/show_bug.cgi?id=1241225#c5 regarding certs source
    file {
        "${cert_dir}/MozFakeCA.cer":
            source => 'puppet:///modules/packages/MozFakeCA.cer';
    }
    file {
        "${cert_dir}/MozRoot.cer":
            source => 'puppet:///modules/packages/MozRoot.cer';
    }
    file {
        "${cert_dir}/MozFakeCA_2017-10-13.cer":
            source => 'puppet:///modules/packages/MozFakeCA_2017-10-13.cer';
    }
    exec {
        'install_mozfakeca':
            command     => "C:\\Windows\\System32\\certutil.exe -addstore Root ${cert_dir}\\MozFakeCA.cer",
            subscribe   => File["${cert_dir}/MozFakeCA.cer"],
            refreshonly => true;
    }
    exec {
        'install_mozroot':
            command     => "C:\\Windows\\System32\\certutil.exe -addstore Root ${cert_dir}\\MozRoot.cer",
            subscribe   => File["${cert_dir}/MozRoot.cer"],
            refreshonly => true;
    }
    exec {
        'install_mozfakeca_2017-10-13':
            command     => "C:\\Windows\\System32\\certutil.exe -addstore Root ${cert_dir}\\MozFakeCA_2017-10-13.cer",
            subscribe   => File["${cert_dir}/MozFakeCA_2017-10-13.cer"],
            refreshonly => true;
    }
    # The spacing in the dword(s) value does not work well with the registry module
    # To work around this we are importing a reg file based on the variables in this manifest
    file {
        "${cert_dir}/mms.reg":
            content => template("${module_name}/mms.reg.erb");
    }
    exec {
        'apply_mms_reg':
            command     => "C:\\Windows\\system32\\reg.exe import c:\\etc\\mozilla_maintenance_service\\mms.reg",
            subscribe   => File["${cert_dir}/mms.reg"],
            refreshonly => true;
    }
}
