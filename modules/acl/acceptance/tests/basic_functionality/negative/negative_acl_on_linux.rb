test_name "Windows ACL Module - Negative - ACL Fails Gracefully on Linux"

confine(:except, :platform => 'windows')

#Negative Unix Manifest
acl_manifest = <<-MANIFEST
file { '/tmp/acl_test':
  ensure => directory
}

acl { '/tmp/acl_test':
  permissions => [
    { identity => 'root', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Verify that the 'acl' Type Does not Work on Non-Windows Agents"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_match(/Error: Could not find a suitable provider for acl/, result.stderr, 'Expected error was not detected!')
  end
end
