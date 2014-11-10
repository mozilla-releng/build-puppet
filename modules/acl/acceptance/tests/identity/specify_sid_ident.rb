test_name 'Windows ACL Module - Specify SID Identity'

confine(:to, :platform => 'windows')

#Globals
os_check_command = "cmd /c ver"
os_check_regex = /Version 5/

target_parent = 'c:/temp'
target = 'c:/temp/specify_sid_ident.txt'
user_id = 'bob'

file_content = 'Magic unicorn rainbow madness!'
verify_content_command = "cat /cygdrive/c/temp/specify_sid_ident.txt"
file_content_regex = /\A#{file_content}\z/

get_user_sid_command = <<-GETSID
cmd /c "wmic useraccount where name='#{user_id}' get sid"
GETSID

sid_regex = /^(S-.+)$/

verify_acl_command = "icacls #{target}"
acl_regex = /.*\\bob:\(F\)/

#Capture the SID for later use.
sid = ''

#Manifest
setup_manifest = <<-MANIFEST
file { '#{target_parent}':
  ensure => directory
}

file { '#{target}':
  ensure  => file,
  content => '#{file_content}',
  require => File['#{target_parent}']
}

user { '#{user_id}':
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}
MANIFEST

#Tests
agents.each do |agent|
  #Determine if running on Windows 2003.
  #Skip if 2003 because the wmic command doesn't work right on Windows 2003.
  step "Determine OS Type"
  on(agent, os_check_command) do |result|
    if os_check_regex =~ result.stdout
      skip_test("This test cannot run on a Windows 2003 system!")
    end
  end

  step "Execute Setup Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => setup_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Get SID of User Account"
  on(agent, get_user_sid_command) do |result|
    sid = sid_regex.match(result.stdout)[1]
  end

  #ACL manifest
  acl_manifest = <<-MANIFEST
  acl { '#{target}':
    permissions => [
      { identity => '#{sid}', rights => ['full'] },
    ],
  }
  MANIFEST

  step "Execute ACL Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_match(acl_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
