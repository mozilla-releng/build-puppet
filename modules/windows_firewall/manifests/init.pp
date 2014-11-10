# Class windows_firewall
#
# This class manages the windows firewall
#
# Parameters:
#   [*ensure*]          - Control the state of the windows firewall
#
# Actions:
#
# Requires:
#
# Usage:
#
#   class { 'windows_firewall':
#     ensure => 'running',
#   }
class windows_firewall (
    $ensure = 'running'
) {

    validate_re($ensure,['^(running|stopped)$'])

    case $::operatingsystemversion {
        'Windows Server 2003','Windows Server 2003 R2','Windows XP': {
          $firewall_name = 'SharedAccess'
        }
        default: {
          $firewall_name = 'MpsSvc'
        }
    }

    case $ensure {
        'running': {
            $enabled = true
            $enabled_data = '1'
        }
        default: {
            $enabled = false
            $enabled_data = '0'
        }
    }

    service { 'windows_firewall':
      ensure => $ensure,
      name   => $firewall_name,
      enable => $enabled,
    }

    registry_value { 'EnableFirewall':
      ensure => 'present',
      path   => 'HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\EnableFirewall',
      type   => 'dword',
      data   => $enabled_data
    }
}
