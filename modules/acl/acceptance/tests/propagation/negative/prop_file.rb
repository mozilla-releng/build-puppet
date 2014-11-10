test_name 'Windows ACL Module - Negative - Set Propagation on a File'

confine(:to, :platform => 'windows')

#Globals
rights = 'full'
prop_type = 'all'
affects_child_type = 'all'
file_content = 'Flying beavers attack Lake Oswego!'

parent_name = 'temp'
target_name = "prop_file"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
user_id = 'bob'

verify_content_command = "cat /cygdrive/c/#{parent_name}/#{target_name}"
file_content_regex = /\A#{file_content}\z/

verify_manifest = /\{ identity => '.*\\bob', rights => \["full"\], affects => 'self_only' \}/
verify_acl_command = "icacls #{target}"
acl_regex = /.*\\bob:\(F\)/

#Manifests
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
    assert_match(verify_manifest, result.stdout, 'Expected ACL change event not detected!')
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
