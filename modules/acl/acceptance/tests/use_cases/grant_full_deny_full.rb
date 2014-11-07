test_name "Windows ACL Module - Inherit 'full' Rights for User's Group on Container and Deny User 'full' Rights on Object in Container"

skip_test("This test requires FM-1277 to be resolved")

confine(:to, :platform => 'windows')

#Globals
test_short_name = 'grant_full_deny_full'
file_content = 'Sad people'

parent_name = 'temp'
target_name = "use_case_#{test_short_name}"
target_child_name = "use_case_child_#{test_short_name}.txt"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
target_child = "#{target}/#{target_child_name}"

verify_content_command = "cat /cygdrive/c/#{parent_name}/#{target_name}/#{target_child_name}"
file_content_regex = /\A#{file_content}\z/

group = 'Administrators'
user_id = 'Administrator'

verify_acl_child_command = "icacls #{target_child}"
target_child_first_ace_regex = /.*\\Administrators:\(F\)/
target_child_second_ace_regex = /.*\\Administrator:\(N\)/

#Manifests
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}

file { "#{target}":
  ensure => directory,
  require => File['#{target_parent}']
}

file { "#{target_child}":
  ensure  => file,
  content => '#{file_content}',
  require => File['#{target}']
}

acl { "#{target}":
  permissions  => [
    { identity => '#{group}',type => 'allow', rights => ['full'] },
  ],
}
->
acl { "#{target_child}":
  permissions  => [
    { identity => '#{user_id}',type => 'deny', rights => ['full'] },
  ],
}
MANIFEST

update_manifest = <<-MANIFEST
file { "#{target_child}":
  ensure  => file,
  content => 'Better Content'
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute ACL Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct for Child"
  on(agent, verify_acl_child_command) do |result|
    assert_match(target_child_first_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_child_second_ace_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Attempt to Update File"
  on(agent, puppet('apply', '--debug'), :stdin => update_manifest) do |result|
    assert_match(/Error:/, result.stderr, 'Expected error was not detected!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
