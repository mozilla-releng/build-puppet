test_name 'Windows ACL Module - Specify User Name Containing Unicode for Identity'

skip_test("This test requires QENG-449 to be resolved")

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = 'c:/temp/specify_unicode_user_ident.txt'
user_id = "user_렝딴슫있처"

file_content = 'Flying Spaghetti Monster wants to save your soul.'
verify_content_command = "cat /cygdrive/c/temp/specify_unicode_user_ident.txt"
file_content_regex = /\A#{file_content}\z/

verify_acl_command = "icacls #{target}"
acl_regex = /.*\\user_렝딴슫있처:\(F\)/

#Manifest
acl_manifest = <<-MANIFEST
file { '#{target_parent}':
  ensure => directory
}

file { '#{target}':
  ensure  => file,
  content => '#{file_content}',
  require => File['#{target_parent}']
}

user { '#{user_id}':
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { '#{target}':
  permissions  => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_match(acl_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'Expected file content is invalid!')
  end
end
