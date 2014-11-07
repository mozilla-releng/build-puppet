test_name 'Windows ACL Module - Allow Mask Specific "AD, S, WA, X" Rights for Identity on File'

confine(:to, :platform => 'windows')

#Globals
mask = "1048868"
target_parent = 'c:/temp'
target = "c:/temp/allow_#{mask}_rights_file.txt"
user_id = "bob"

file_content = 'The puppets are controlling my mind!'
verify_content_command = "cat /cygdrive/c/temp/allow_#{mask}_rights_file.txt"
file_content_regex = /\A#{file_content}\z/

verify_acl_command = "icacls #{target}"
acl_regex = /.*\\bob:\(S,AD,X,WA\)/

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
    { identity => '#{user_id}', rights => ['mask_specific'], mask => '#{mask}' },
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
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
