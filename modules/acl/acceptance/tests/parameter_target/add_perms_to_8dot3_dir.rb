test_name 'Windows ACL Module - Add Permissions to a 8.3 Directory'

skip_test("This test requires FM-1164 to be resolved")

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = 'c:/temp/dir_short_name'
target8dot3 = 'c:/temp/DIR_SH~1'
user_id = 'bob'

verify_acl_command = "icacls #{target8dot3}"
acl_regex = /.*\\bob:\(OI\)\(CI\)\(F\)/

#Manifest
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}

file { "#{target}":
  ensure  => directory,
  require => File['#{target_parent}']
}

user { "#{user_id}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { "#{target8dot3}":
  permissions => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_match(acl_regex, result.stdout, 'Expected ACL was not present!')
  end
end
