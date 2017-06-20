# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::disable_desktop_interruption {

    include dirs::programdata::puppetagain

    $hkey_user_desktop = '"HKCU\Control Panel\Desktop"'
    $hkey_user_advance = '"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"'
    $reg_add_desktop   = "reg add ${hkey_user_desktop} /v"
    $reg_add_advance   = "reg add ${hkey_user_advance} /v"
    $reg_options       = '/t REG_SZ /d 0 /f'
    $script_dir        = 'C:\programdata\puppetagain'
    $script_file_dir   = 'C:/programdata/puppetagain'
    $schtask           = 'C:\Windows\system32\schtasks.exe'
    $tn_flag           = '/TN disable_desktop_interrupt'
    $builder_username  = $users::builder::username

    # The tray.reg file covers the disabling of a wide range of notifications
    # This is being applied as a reg file since one registry value is 700+ lines
    # This file originates from the GPO from domain management
    # The file is being kept intact in order to be catious in regards of not breaking tests

    # The disable_desktop_interrupt.bat will disable the screens saver and balloon notifications 
    # Because these values are within the Hkey Current User and that hive is not created until the first log on of the user Puppet can not directly managed it in a first run scenario
    # The last portion sets up a schedule task that will run on the first login of the build user
    # The disable_desktop_interrupt.bat will also apply the tray.reg file and will delete the the schedule task that runs it

    file {
        "${script_file_dir}/tray.reg" :
            source  => 'puppet:///modules/tweaks/tray.reg',
            require => Class['dirs::programdata::puppetagain'];
    }
    file {
        "${script_file_dir}/disable_desktop_interrupt.bat" :
            content => template("${module_name}/disable_desktop_interrupt.bat.erb"),
            require => Class['dirs::programdata::puppetagain'];
    }
    file {
        "${script_file_dir}/disable_desktop_interrupt.xml" :
            content => template("${module_name}/disable_desktop_interrupt.xml.erb"),
            require => Class['dirs::programdata::puppetagain'];
    }
    exec {
        'disable_desktop_interrupt_schtask':
            command     => "${schtask} /Create /XML  ${script_dir}\\disable_desktop_interrupt.xml /TN disable_desktop_interrupt",
            subscribe   => File["${script_file_dir}/disable_desktop_interrupt.bat"],
            refreshonly => true;
    }
}
