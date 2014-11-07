test_name 'Windows ACL Module - Purge All Other Permissions from Directory without Inheritance'

confine(:to, :platform => 'windows')

#Globals
os_check_command = "cmd /c ver"
os_check_regex = /Version 5/
os_version_win_2003 = false

target_parent = 'c:/temp'
target = "c:/temp/purge_all_other_no_inherit"
user_id_1 = 'bob'
user_id_2 = 'jerry'

verify_acl_command = "icacls #{target}"
acl_regex_user_id_1 = /.*\\bob:\(OI\)\(CI\)\(F\)/
acl_regex_user_id_2 = /\Ac:\/temp\/purge_all_other_no_inherit.*\\jerry:\(OI\)\(CI\)\(F\)\n\nSuccessfully/
acl_regex_win_2003 = /c:\/temp\/purge_all_other_no_inherit: Access is denied\./

#Manifests
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}

file { "#{target}":
  ensure  => directory,
  require => File['#{target_parent}']
}

user { "#{user_id_1}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_2}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { "#{target}":
  permissions  => [
    { identity => '#{user_id_1}', rights => ['full'] },
  ],
}
MANIFEST

purge_acl_manifest = <<-MANIFEST
acl { "#{target}":
  purge        => 'true',
  permissions  => [
    { identity => '#{user_id_2}', rights => ['full'] },
  ],
  inherit_parent_permissions => 'false'
}
MANIFEST

#Tests
agents.each do |agent|
  step "Determine OS Type"
  on(agent, os_check_command) do |result|
    if os_check_regex =~ result.stdout
      os_version_win_2003 = true
    end
  end

  step "Execute Apply Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_match(acl_regex_user_id_1, result.stdout, 'Expected ACL was not present!')
  end

  step "Execute Purge Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => purge_acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct (Post-Purge)"
  on(agent, verify_acl_command, :acceptable_exit_codes => [0,5]) do |result|
    if os_version_win_2003
      assert_match(acl_regex_win_2003, result.stderr, 'Expected failure was not present!')
    else
      assert_no_match(acl_regex_user_id_1, result.stdout, 'Unexpected ACL was present!')
      assert_match(acl_regex_user_id_2, result.stdout, 'Expected ACL was not present!')
    end
  end
end
