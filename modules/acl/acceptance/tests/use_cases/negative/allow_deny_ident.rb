test_name "Windows ACL Module - Negative - Allow and Deny ACE for Single Identity in ACL"

confine(:to, :platform => 'windows')

#Globals
test_short_name = 'allow_deny_ident'
file_content = 'Epic fail'

parent_name = 'temp'
target_name = "use_case_#{test_short_name}.txt"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"

verify_content_command = "cat /cygdrive/c/#{parent_name}/#{target_name}"
file_content_regex = /\A#{file_content}\z/

user_id = 'bob'

verify_acl_command = "icacls #{target}"
target_first_ace_regex = /.*\\bob:\(F\)/
target_second_ace_regex = /.*\\bob:\(N\)/

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

acl { "#{target}":
  permissions  => [
    { identity => '#{user_id}',type => 'allow', rights => ['full'] },
    { identity => '#{user_id}',type => 'deny', rights => ['full'] }
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
    assert_match(target_first_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(target_second_ace_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
