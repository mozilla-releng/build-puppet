test_name 'Windows ACL Module - Only Purge Explicit Permissions from Directory with Inheritance'

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = "c:/temp/purge_exp_inherit"
user_id_1 = 'bob'
user_id_2 = 'jerry'

verify_acl_command = "icacls #{target}"
acl_regex_user_id_1 = /.*\\bob:\(OI\)\(CI\)\(F\)/
acl_regex_user_id_2 = /.*\\jerry:\(OI\)\(CI\)\(F\)/

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
}
MANIFEST

#Tests
agents.each do |agent|
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
  on(agent, verify_acl_command) do |result|
    assert_no_match(acl_regex_user_id_1, result.stdout, 'Unexpected ACL was present!')
    assert_match(acl_regex_user_id_2, result.stdout, 'Expected ACL was not present!')
  end
end
