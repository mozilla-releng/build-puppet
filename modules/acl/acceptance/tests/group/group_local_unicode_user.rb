test_name 'Windows ACL Module - Change Group to Local Unicode User'

skip_test("This test requires QENG-449 to be resolved")

confine(:to, :platform => 'windows')

#Globals
user_type = 'local_unicode_user'
file_content = 'Burning grass on a cold winter day.'

parent_name = 'temp'
target_name = "group_#{user_type}.txt"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
user_id = 'bob'
group_id = 'ΣΤΥΦ'

verify_content_command = "cat /cygdrive/c/#{parent_name}/#{target_name}"
file_content_regex = /\A#{file_content}\z/

verify_group_command = "icacls #{target}"
group_regex = /.*\\ΣΤΥΦ:\(M\)/

#Manifests
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}

file { "#{target}":
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

user { "#{group_id}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { "#{target}":
  purge           => 'true',
  permissions     => [
    { identity    => 'CREATOR GROUP',
      rights      => ['modify']
    },
    { identity    => '#{user_id}',
      rights      => ['read']
    },
    { identity    => 'Administrators',
      rights      => ['full'],
      affects     => 'all',
      child_types => 'all'
    }
  ],
  group           => '#{group_id}',
  inherit_parent_permissions => 'false'
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute ACL Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_group_command) do |result|
    assert_match(group_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
