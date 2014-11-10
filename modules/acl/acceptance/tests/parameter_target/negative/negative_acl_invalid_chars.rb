test_name 'Windows ACL Module - Negative - Specify Target with Invalid Path Characters'

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = 'c:/temp/invalid_<:>|?*'
user_id = 'bob'

#Manifest
acl_manifest = <<-MANIFEST
file { "#{target_parent}":
  ensure => directory
}
->
user { "#{user_id}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}
->
acl { "#{target}":
  permissions  => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_match(/Error:.*The filename, directory name, or volume label syntax is incorrect/,
      result.stderr, 'Expected error was not detected!')
  end
end
