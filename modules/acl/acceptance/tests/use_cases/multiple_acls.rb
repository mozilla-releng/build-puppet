test_name 'Windows ACL Module - ACL for Parent Path with Separate ACL for Child Path'

confine(:to, :platform => 'windows')

#Globals
test_short_name = 'multi_acl'

parent_name = 'temp'
target_name = "use_case_#{test_short_name}"
target_child_name = "use_case_child_#{test_short_name}"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
target_child = "#{target}/#{target_child_name}"

user_id_1 = 'bob'
user_id_2 = 'jerry'
user_id_3 = 'billy'
user_id_4 = 'sarah'
user_id_5 = 'sally'
user_id_6 = 'betty'

verify_acl_command = "icacls #{target}"
verify_acl_child_command = "icacls #{target_child}"
user_id_1_ace_regex = /.*\\bob:(\(I\))?\(OI\)\(CI\)\(M\)/
user_id_2_ace_regex = /.*\\jerry:(\(I\))?\(OI\)\(CI\)\(N\)/
user_id_3_ace_regex = /.*\\billy:(\(I\))?\(OI\)\(CI\)\(W,Rc\)/
user_id_4_ace_regex = /.*\\sarah:\(OI\)\(CI\)\(N\)/
user_id_5_ace_regex = /.*\\sally:\(OI\)\(CI\)\(M\)/
user_id_6_ace_regex = /.*\\betty:\(OI\)\(CI\)\(DENY\)\(R\)/

#Manifests
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}

file { "#{target}":
  ensure  => directory,
  require => File['#{target_parent}']
}

file { "#{target_child}":
  ensure  => directory,
  require => File['#{target}']
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

user { "#{user_id_3}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_4}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_5}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_6}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { "#{target}":
  permissions  => [
    { identity => '#{user_id_1}', type => 'allow', rights => ['modify'] },
    { identity => '#{user_id_2}', type => 'deny', rights => ['full'] },
    { identity => '#{user_id_3}', type => 'allow', rights => ['write'] }
  ],
}
->
acl { "#{target_child}":
  permissions  => [
    { identity => '#{user_id_4}', type => 'deny', rights => ['full'] },
    { identity => '#{user_id_5}', type => 'allow', rights => ['modify'] },
    { identity => '#{user_id_6}', type => 'deny', rights => ['read'] }
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute ACL Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_match(user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_3_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_no_match(user_id_4_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_no_match(user_id_5_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_no_match(user_id_6_ace_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify that ACL Rights are Correct for Child"
  on(agent, verify_acl_child_command) do |result|
    assert_match(user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_3_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_4_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_5_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_6_ace_regex, result.stdout, 'Expected ACL was not present!')
  end
end
