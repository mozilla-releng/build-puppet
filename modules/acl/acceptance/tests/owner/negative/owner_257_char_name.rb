test_name 'Windows ACL Module - Negative - Specify 257 Character String for Owner'

confine(:to, :platform => 'windows')

#Globals
user_type = '257_char_name'
file_content = 'I AM TALKING VERY LOUD!'

parent_name = 'temp'
target_name = "owner_#{user_type}.txt"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"
user_id = 'bob'
owner_id = 'jasqddsweruwqiouroaysfyuasudyfaisoyfqoiuwyefiaysdiyfzixycivzixyvciqywifyiasdiufyasdygfasirfwerqiuwyeriatsdtfastdfqwyitfastdfawerfytasdytfasydgtaisdytfiasydfiosayghiayhidfhygiasftawyegyfhgaysgfuyasgdyugfasuiyfguaqyfgausydgfaywgfuasgdfuaisydgfausasdfuygsadfyg'

expected_error = /Error:.*User does not exist/
verify_content_command = "cat /cygdrive/c/#{parent_name}/#{target_name}"
file_content_regex = /\A#{file_content}\z/

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

user { "#{user_id}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { "#{target}":
  permissions  => [
    { identity => '#{user_id}',
      rights   => ['modify']
    },
  ],
  owner        => '#{owner_id}'
}
MANIFEST

#Tests
agents.each do |agent|
  step "Attempt to Execute ACL Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_match(expected_error, result.stderr, 'Expected error was not detected!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
