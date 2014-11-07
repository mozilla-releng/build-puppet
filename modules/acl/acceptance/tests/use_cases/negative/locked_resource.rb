test_name "Windows ACL Module - Negative - Manage Locked Resource with ACL "

confine(:to, :platform => 'windows')

#Globals
test_short_name = 'locked_resource'
file_content = 'Why this hurt bad!'

parent_name = 'temp'
target_name = "use_case_#{test_short_name}.txt"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"

file_content_regex = /\A#{file_content}\z/

user_id = 'bob'

verify_acl_command = "icacls #{target}"
target_acl_regex = /.*\\bob:\(F\)/

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
  purge        => 'true',
  permissions  => [
    { identity => '#{user_id}', rights => ['full'] }
  ],
  inherit_parent_permissions => 'false'
}
MANIFEST

update_manifest = <<-MANIFEST
file { "#{target}":
  ensure  => file,
  content => 'New Content'
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute ACL Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Attempt to Update File"
  on(agent, puppet('apply', '--debug'), :stdin => update_manifest) do |result|
    assert_match(/Error:.*Permission denied/, result.stderr, 'Expected error was not detected!')
  end
end
