test_name 'Windows ACL Module - Remove Permissions from a 8.3 Directory'

skip_test("This test requires FM-1164 to be resolved")

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = 'c:/temp/rem_dir_short_name'
target8dot3 = 'c:/temp/REM_DI~1'
user_id = 'bob'

verify_acl_command = "icacls #{target8dot3}"
acl_regex = /.*\\bob:\(OI\)\(CI\)\(F\)/

#Apply Manifest
acl_manifest_apply = <<-MANIFEST
file { '#{target_parent}':
  ensure => directory
}

file { '#{target}':
  ensure  => directory,
  require => File['#{target_parent}']
}

user { '#{user_id}':
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { '#{target8dot3}':
  permissions => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Remove Manifest
acl_manifest_remove = <<-MANIFEST
acl { '#{target8dot3}':
  purge => 'listed_permissions',
  permissions => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute Apply Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest_apply) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_match(acl_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Execute Remove Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest_remove) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_no_match(acl_regex, result.stdout, 'Unexpected ACL was present!')
  end
end
