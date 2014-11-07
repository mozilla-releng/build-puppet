test_name 'Windows ACL Module - Negative - Specify Symlink as Target'

confine(:to, :platform => 'windows')

#Globals
os_check_command = "cmd /c ver"
os_check_regex = /Version 5/

target_parent = 'c:/temp'
target = 'c:/temp/sym_target_file.txt'
target_symlink = 'c:/temp/symlink'
user_id = 'bob'

file_content = 'A link to the past.'
verify_content_command = "cat /cygdrive/c/temp/sym_target_file.txt"
file_content_regex = /\A#{file_content}\z/

win_target = "c:\\temp\\sym_target_file.txt"
win_target_symlink = "c:\\temp\\symlink"
mklink_command = "c:\\windows\\system32\\cmd.exe /c mklink #{win_target_symlink} #{win_target}"

verify_acl_command = "icacls #{target_symlink}"
acl_regex = /.*\\bob:\(F\)/

#Manifest
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}

file { '#{target}':
  ensure  => file,
  content => '#{file_content}',
  require => File['#{target_parent}']
}

user { "#{user_id}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!",
  require => File['#{target}']
}

exec { 'Create Windows Symlink':
  command => '#{mklink_command}',
  creates => '#{target_symlink}',
  cwd     => '#{target_parent}',
  require => User['#{user_id}']
}

acl { "#{target_symlink}":
  permissions  => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
  require      => Exec['Create Windows Symlink']
}
MANIFEST

#Tests
agents.each do |agent|
  #Determine if running on Windows 2003.
  #Skip if 2003 since MKLINK is not available.
  step "Determine OS Type"
  on(agent, os_check_command) do |result|
    if os_check_regex =~ result.stdout
      skip_test("This test cannot run on a Windows 2003 system!")
    end
  end

  step "Execute Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_no_match(acl_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'Expected file content is invalid!')
  end
end
