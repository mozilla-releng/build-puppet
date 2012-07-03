class disableservices::common {
# This class disables unnecessary services common to both server and slave
    case $operatingsystem {
        CentOS : {
            service {
                ['acpid', 'anacron', 'apmd', 'atd', 'auditd', 'autofs',
                'avahi-daemon', 'avahi-dnsconfd', 'bluetooth', 'cpuspeed',
                'cups', 'cups-config-daemon', 'gpm', 'hidd', 'hplip', 'kudzu',
                'mcstrans', 'mdmonitor', 'pcscd', 'restorecond', 'rpcgssd',
                'rpcidmapd', 'sendmail', 'smartd', 'vncserver',
                'yum-updatesd'] :
                    ensure => stopped,
            }
        }
        Darwin : {
            service {
                ['com.apple.blued'] :
                    enable => false,
                    ensure => stopped,
            }
        }
    }
}
