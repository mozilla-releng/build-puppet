test_name 'Windows ACL Module - Multiple ACL for Nested Paths with Varying Rights for Same Identity'

confine(:to, :platform => 'windows')

#Globals
test_short_name = 'multi_acl_shared_ident'

parent_name = 'temp'
target_name = "use_case_#{test_short_name}"
target_child_name = "use_case_child_#{test_short_name}"
target_grand_child_name = "use_case_grand_child_#{test_short_name}"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
target_child = "#{target}/#{target_child_name}"
target_grand_child = "#{target_child}/#{target_grand_child_name}"

group_1 = 'jerks'
group_2 = 'cool_peeps'

user_id_1 = 'bob'
user_id_2 = 'jerry'

verify_acl_command = "icacls #{target}"
verify_acl_child_command = "icacls #{target_child}"
verify_acl_grand_child_command = "icacls #{target_grand_child}"

target_group_1_ace_regex = /.*\\jerks:(\(I\))?\(OI\)\(CI\)\(R\)/
target_group_2_ace_regex = /.*\\cool_peeps:(\(I\))?\(OI\)\(CI\)\(R\)/
target_user_id_1_ace_regex = /.*\\bob:(\(I\))?\(OI\)\(CI\)\(R\)/
target_user_id_2_ace_regex = /.*\\jerry:(\(I\))?\(OI\)\(CI\)\(DENY\)\(RX\)/

target_child_group_1_ace_regex = /.*\\jerks:(\(I\))?\(OI\)\(CI\)\(Rc,S,X,RA\)/
target_child_group_2_ace_regex = /.*\\cool_peeps:(\(I\))?\(OI\)\(CI\)\(Rc,S,X,RA\)/
target_child_user_id_1_ace_regex = /.*\\bob:(\(I\))?\(OI\)\(CI\)\(W,Rc\)/
target_child_user_id_2_ace_regex = /.*\\jerry:(\(I\))?\(OI\)\(CI\)\(DENY\)\(W,Rc\)/

target_grand_child_group_1_ace_regex = /.*\\jerks:\(OI\)\(CI\)\(F\)/
target_grand_child_group_2_ace_regex = /.*\\cool_peeps:\(OI\)\(CI\)\(F\)/
target_grand_child_user_id_1_ace_regex = /.*\\bob:\(OI\)\(CI\)\(N\)/
target_grand_child_user_id_2_ace_regex = /.*\\jerry:\(OI\)\(CI\)\(N\)/

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

file { "#{target_grand_child}":
  ensure  => directory,
  require => File['#{target_child}']
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

acl { "#{target}":
  permissions  => [
    { identity => '#{user_id_1}', type => 'allow', rights => ['read'] },
    { identity => '#{user_id_2}', type => 'deny', rights => ['read','execute'] },
    { identity => '#{group_1}', type => 'allow', rights => ['read'] },
    { identity => '#{group_2}', type => 'allow', rights => ['read'] }
  ],
}
->
acl { "#{target_child}":
  permissions  => [
    { identity => '#{user_id_1}', type => 'allow', rights => ['write'] },
    { identity => '#{user_id_2}', type => 'deny', rights => ['write'] },
    { identity => '#{group_1}', type => 'allow', rights => ['execute'] },
    { identity => '#{group_2}', type => 'allow', rights => ['execute'] }
  ],
}
->
acl { "#{target_grand_child}":
  permissions  => [
    { identity => '#{user_id_1}', type => 'deny', rights => ['full'] },
    { identity => '#{user_id_2}', type => 'deny', rights => ['full'] },
    { identity => '#{group_1}', type => 'allow', rights => ['full'] },
    { identity => '#{group_2}', type => 'allow', rights => ['full'] },
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
    assert_match(target_group_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_group_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify that ACL Rights are Correct for Child"
  on(agent, verify_acl_child_command) do |result|
    #ACL from parent(s) will still apply.
    assert_match(target_group_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_group_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')

    assert_match(target_child_group_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_child_group_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_child_user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_child_user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify that ACL Rights are Correct for Grand Child"
  on(agent, verify_acl_grand_child_command) do |result|
    #ACL from parent(s) will still apply.
    assert_match(target_group_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_group_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')

    #ACL from parent(s) will still apply.
    assert_match(target_child_group_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_child_group_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_child_user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_child_user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')

    assert_match(target_grand_child_group_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_group_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_grand_child_user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')
  end
end
