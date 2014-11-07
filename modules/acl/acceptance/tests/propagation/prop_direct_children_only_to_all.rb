test_name 'Windows ACL Module - Propagate "direct_children_only" to "all" Child Types'

confine(:to, :platform => 'windows')

#Globals
rights = 'full'
prop_type = 'direct_children_only'
affects_child_type = 'all'

parent_name = 'temp'
target_name = "prop_#{prop_type}_to_#{affects_child_type}"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
user_id = 'bob'

verify_acl_command = "icacls #{target}"
acl_regex = /.*\\bob:\(OI\)\(CI\)\(NP\)\(IO\)\(F\)/

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
  purge           => 'true',
  permissions     => [
    { identity    => '#{user_id}',
      rights      => ['#{rights}'],
      affects     => '#{prop_type}',
      child_types => '#{affects_child_type}'
    },
    { identity    => 'Administrators',
      rights      => ['full'],
      affects     => 'all',
      child_types => 'all'
    }
  ],
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
    assert_match(acl_regex, result.stdout, 'Expected ACL was not present!')
  end
end
