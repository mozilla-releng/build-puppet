# Class windows_firewall::exception
#
# This class manages exceptions in the windows firewall
#
# Parameters:
#   [*ensure*]          - Control the existence of a rule
#   [*direction]        - Specifies whether this rule matches inbound or outbound network traffic.
#   [*action]           - Specifies what Windows Firewall with Advanced Security does to filter network packets that match the criteria specified in this rule.
#   [*enabled]          - Specifies whether the rule is currently enabled.
#   [*protocol]         - Specifies that network packets with a matching IP protocol match this rule.
#   [*local_port]       - Specifies that network packets with matching IP port numbers matched by this rule.
#   [*display_name]     - Specifies the rule name assigned to the rule that you want to display
#   [*description]      - Provides information about the firewall rule.
#
# Actions:
#
# Requires:
#
# Usage:
#
#  By protocol/port:
#
#   windows_firewall::exception { 'WINRM-HTTP-In-TCP':
#     ensure       => present,
#     direction    => 'in',
#     action       => 'Allow',
#     enabled      => 'yes',
#     protocol     => 'TCP',
#     local_port   => '5985',
#     program      => undef,
#     display_name => 'Windows Remote Management HTTP-In',
#     description  => 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]',
#   }
#
#  By program path:
#
#   windows_firewall::exception { 'myapp':
#     ensure       => present,
#     direction    => 'in',
#     action       => 'Allow',
#     enabled      => 'yes',
#     program      => 'C:\\myapp.exe',
#     display_name => 'My App',
#     description  => 'Inbound rule for My App',
#   }
#
define windows_firewall::exception(
  $ensure = 'present',
  $direction = '',
  $action = '',
  $enabled = 'yes',
  $protocol = '',
  $local_port = '',
  $program = undef,
  $display_name = '',
  $description = '',

) {

    # Check if we're allowing a program or port/protocol and validate accordingly
    if $program == undef {
      #check whether to use 'localport', or just 'port' depending on OS
      case $::operatingsystemversion {
        /Windows Server 2003/, /Windows XP/: {
          $port_param = 'port'
        }
        default: {
          $port_param = 'localport'
        }
      }
      $fw_command = 'portopening'
      $allow_context = "protocol=${protocol} ${port_param}=${local_port}"
      validate_re($protocol,['^(TCP|UDP)$'])
      validate_re($local_port,['[0-9]{1,5}'])
    } else {
      $fw_command = 'allowedprogram'
      $allow_context = "program=\"${program}\""
      validate_absolute_path($program)
    }

    # Validate common parameters
    validate_re($ensure,['^(present|absent)$'])
    validate_slength($display_name,255)
    validate_re($enabled,['^(yes|no)$'])

    case $::operatingsystemversion {
      'Windows Server 2012', 'Windows Server 2008', 'Windows Server 2008 R2', 'Windows Vista','Windows 7','Windows 8': {
        validate_slength($description,255)
        validate_re($direction,['^(in|out)$'])
        validate_re($action,['^(allow|block)$'])
      }
      default: { }
    }

    # Set command to check for existing rules
    $check_rule_existance= "C:\\Windows\\System32\\netsh.exe advfirewall firewall show rule name=\"${display_name}\""

    # Use unless for exec if we want the rule to exist
    if $ensure == 'present' {
        $fw_action = 'add'
        $unless = $check_rule_existance
        $onlyif = undef
    } else {
    # Or onlyif if we expect it to be absent
        $fw_action = 'delete'
        $onlyif = $check_rule_existance
        $unless = undef
    }


    case $::operatingsystemversion {
      /Windows Server 2003/, /Windows XP/: {
        $mode = $enabled ? {
          'yes' => 'ENABLE',
          'no'  => 'DISABLE',
        }
        $netsh_command = "C:\\Windows\\System32\\netsh.exe firewall ${fw_action} ${fw_command} name=\"${display_name}\" mode=${mode} ${allow_context}"
      }
      default: {
        $netsh_command = "C:\\Windows\\System32\\netsh.exe advfirewall firewall ${fw_action} rule name=\"${display_name}\" description=\"${description}\" dir=${direction} action=${action} enable=${enabled} ${allow_context}"
      }
    }

    exec { "set rule ${display_name}":
      command  => $netsh_command,
      provider => windows,
      onlyif   => $onlyif,
      unless   => $unless,
    }
}
