test_name 'Windows ACL Module - Remove Permissions from a File with a Long Name (259 chars)'

skip_test("This test requires PE-3075 to be resolved")

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = 'c:/temp/rem_file_zeeNxWihARGLytPggNssxewZsopUFUoncTKAgsxsBqRigMlZEdNTEybqlVTjkDWTRASaQPyeeAsuUohncMlarIRphqIdqwyimqPphRTcKpojhTHoAgTUWiaEkiOqbeeEZKvNAhFQiELGLZghRwhKXVHuUPxWghKXVHuUPxWqmeYCHejdQOoGRYqaxwdIqiYyhhSCAhEWlggsGToSLmrgPmotSACKrREyohRBPaKRUmlgCGVtrP'
user_id = 'bob'

file_content = 'Happy Happy Happy Happy Happy!'
verify_content_command = "cat /cygdrive/c/temp/rem_file_zeeNxWihARGLytPggNssxewZsopUFUoncTKAgsxsBqRigMlZEdNTEybqlVTjkDWTRASaQPyeeAsuUohncMlarIRphqIdqwyimqPphRTcKpojhTHoAgTUWiaEkiOqbeeEZKvNAhFQiELGLZghRwhKXVHuUPxWghKXVHuUPxWqmeYCHejdQOoGRYqaxwdIqiYyhhSCAhEWlggsGToSLmrgPmotSACKrREyohRBPaKRUmlgCGVtrP"
file_content_regex = /\A#{file_content}\z/

verify_acl_command = "icacls #{target}"
acl_regex = /.*\\bob:\(F\)/

#Apply Manifest
acl_manifest_apply = <<-MANIFEST
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
  permissions => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Remove Manifest
acl_manifest_remove = <<-MANIFEST
acl { '#{target}':
  purge => 'listed_permissions',
  permissions => [
    { identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute Apply Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest_apply) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_match(acl_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Execute Remove Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest_remove) do |result|
    assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
  end

  step "Verify that ACL Rights are Correct"
  on(agent, verify_acl_command) do |result|
    assert_no_match(acl_regex, result.stdout, 'Unexpected ACL was present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'Expected file content is invalid!')
  end
end
