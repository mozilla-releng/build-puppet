test_name 'Windows ACL Module - Allow "read" Rights for Identity on Directory'

confine(:to, :platform => 'windows')

#Globals
rights = "read"
target_parent = 'c:/temp'
target = "c:/temp/allow_#{rights}_rights_dir"
user_id = "bob"

verify_acl_command = "icacls #{target}"
acl_regex = /.*\\bob:\(OI\)\(CI\)\(R\)/

#Manifest
acl_manifest = <<-MANIFEST
file { '#{target_parent}':
  ensure => directory
}

file { '#{target}':
  ensure  => directory,
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
    { identity => '#{user_id}', type => 'allow', rights => ['#{rights}'] },
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
end
