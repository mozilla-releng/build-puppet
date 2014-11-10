test_name 'Windows ACL Module - Negative - Specify Blank Target'

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = ''
user_id = 'bob'

#Manifest
acl_manifest = <<-MANIFEST
acl { "#{target}":
  permissions  => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest, :acceptable_exit_codes => [1]) do |result|
    assert_match(/Error:.*A non-empty name must be specified/, result.stderr, 'Expected error was not detected!')
  end
end
