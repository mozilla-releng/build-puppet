test_name 'Windows ACL Module - Negative - Purge Absolutely All Permissions from Directory without Inheritance'

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = "c:/temp/purge_all_no_inherit"
user_id = 'bob'

verify_acl_command = "icacls #{target}"
acl_regex_user_id = /.*\\bob:\(OI\)\(CI\)\(F\)/

verify_purge_error = /Error:.*Value for permissions should be an array with at least one element specified/

#Manifests
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

acl { "#{target}":
  permissions  => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

purge_acl_manifest = <<-MANIFEST
acl { "#{target}":
  purge        => 'true',
  permissions  => [],
  inherit_parent_permissions => 'false'
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
    assert_match(acl_regex_user_id, result.stdout, 'Expected ACL was not present!')
  end

  step "Attempt to Execute Purge Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => purge_acl_manifest, :acceptable_exit_codes => [1]) do |result|
    assert_match(verify_purge_error, result.stderr, 'Expected error was not detected!')
  end
end
