test_name 'Windows ACL Module - Complex Propagation and Inheritance with Nested Paths'

confine(:to, :platform => 'windows')

#Globals
test_short_name = 'complex_prop_inherit'
file_content = 'Sight seeing blind people.'

parent_name = 'temp'
target_name = "use_case_#{test_short_name}"
target_child_name = "use_case_child_#{test_short_name}"
target_grand_child_name = "use_case_grand_child_#{test_short_name}.txt"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
target_child = "#{target}/#{target_child_name}"
target_grand_child = "#{target_child}/#{target_grand_child_name}"

verify_content_command = "cat /cygdrive/c/#{parent_name}/#{target_name}/#{target_child_name}/#{target_grand_child_name}"
file_content_regex = /\A#{file_content}\z/

group_1 = 'jerks'
group_2 = 'cool_peeps'

user_id_1 = 'bob'
user_id_2 = 'jerry'

verify_acl_grand_child_command = "icacls #{target_grand_child}"

target_grand_child_first_ace_regex = /.*\\cool_peeps:\(N\)/
target_grand_child_second_ace_regex = /.*\\bob:\(I\)\(DENY\)\(M\)/
target_grand_child_third_ace_regex = /.*\\Administrators:\(I\)\(F\)/
target_grand_child_fourth_ace_regex = /.*\\bob:\(I\)\(R\)/
target_grand_child_fifth_ace_regex = /.*\\jerry:\(I\)\(DENY\)\(RX\)/
target_grand_child_sixth_ace_regex = /.*\\cool_peeps:\(I\)\(R\)/

#Manifests
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}

group { "#{group_1}":
  ensure => present
}

group { "#{group_2}":
  ensure => present
}

user { "#{user_id_1}":
  ensure     => present,
  groups     => ['Users', '#{group_1}'],
  managehome => true,
  password   => "L0v3Pupp3t!",
  require => Group['#{group_1}']
}

user { "#{user_id_2}":
  ensure     => present,
  groups     => ['Users', '#{group_2}'],
  managehome => true,
  password   => "L0v3Pupp3t!",
  require => Group['#{group_2}']
}

file { "#{target}":
  ensure  => directory,
  require => File['#{target_parent}']
}
->
acl { "#{target}":
  purge           => 'true',
  permissions     => [
    { identity    => 'Administrators',type => 'allow', rights => ['full'] },
    { identity    => '#{user_id_1}',
      type        => 'allow',
      rights      => ['read'],
      affects     => 'children_only',
      child_types => 'all'
    },
    { identity    => '#{user_id_2}',
      type        => 'deny',
      rights      => ['read','execute'],
      affects     => 'children_only',
      child_types => 'objects'
    },
    { identity    => '#{group_1}',
      type        => 'allow',
      rights      => ['read'],
      affects     => 'children_only',
      child_types => 'containers'
    },
    { identity    => '#{group_2}',
      type        => 'allow',
      rights      => ['read'],
      affects     => 'children_only',
      child_types => 'all'
    }
  ],
  inherit_parent_permissions => 'false'
}
->
file { "#{target_child}":
  ensure  => directory
}
->
acl { "#{target_child}":
  purge           => 'true',
  permissions     => [
    { identity    => '#{user_id_1}',
      type        => 'deny',
      rights      => ['modify'],
      affects     => 'children_only',
      child_types => 'objects'
    },
    { identity    => '#{user_id_2}',
      type        => 'allow',
      rights      => ['full'],
      affects     => 'children_only',
      child_types => 'containers'
    }
  ],
}
->
file { "#{target_grand_child}":
  ensure  => file,
  content => '#{file_content}'
}
->
acl { "#{target_grand_child}":
  permissions  => [
    { identity    => '#{group_2}',
      type        => 'deny',
      rights      => ['full'],
      affects     => 'self_only'
    }
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute ACL Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct for Grand Child"
  on(agent, verify_acl_grand_child_command) do |result|
    #We only need to check the grand child because we are only concerned with rights
    #propagating and inheriting.
    assert_match(target_grand_child_first_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_second_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_third_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_fourth_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_fifth_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_sixth_ace_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
