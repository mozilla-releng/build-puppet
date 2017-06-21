class pf {

    # Default ethernet interface
    $iface  = 'en0'
    $pf_dir = '/etc/pf.mozilla.anchors'
    $pfctl  = '/sbin/pfctl'
    $pf_entry = '/etc/pf.conf'

    file { $pf_dir:
        ensure => 'directory',
        owner  => 'root',
        group  => '0',
        mode   => '0700',
    }->
    file { "${pf_dir}/main.conf":
        ensure => present,
        owner  => 'root',
        group  => '0',
        mode   => '0600',
        content => template('pf/main.conf.erb'),
        notify => Exec['update_pf'],
    }->
    concat { "${pf_dir}/tables.conf":
        owner  => 'root',
        group  => '0',
        mode   => '0600',
        notify => Exec['update_pf'],
    }->
    concat { "${pf_dir}/rules.conf":
        owner => 'root',
        group => '0',
        mode  => '0600',
        notify => Exec['update_pf'],
    }->
    file { $pf_entry:
        ensure => present,
        owner => 'root',
        group => '0',
        source => 'puppet:///modules/pf/pf.conf',
    }
    file { '/Library/LaunchDaemons/org.mozilla.pf.plist':
        ensure => present,
        source => 'puppet:///modules/pf/org.mozilla.pf.plist',
    }
    exec { 'update_pf':
        command => "${pfctl} -nf ${pf_entry} && ${pfctl} -f ${pf_entry}",
        refreshonly => true,
    }~>
    exec { 'enable_pf':
        command => "${pfctl} -e",
        refreshonly => true,
    }
}
