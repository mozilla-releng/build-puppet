test_name 'Windows ACL Module - Multiple ACEs for Target Path'

confine(:to, :platform => 'windows')

#Globals
test_short_name = 'multi_aces'
file_content = 'Ninjas all up in my face!'

parent_name = 'temp'
target_name = "use_case_#{test_short_name}.txt"

target_parent = "c:/#{parent_name}"
target = "#{target_parent}/#{target_name}"

user_id_1 = 'bob'
user_id_2 = 'jerry'
user_id_3 = 'billy'
user_id_4 = 'sarah'
user_id_5 = 'sally'
user_id_6 = 'betty'

verify_content_command = "cat /cygdrive/c/#{parent_name}/#{target_name}"
file_content_regex = /\A#{file_content}\z/

verify_acl_command = "icacls #{target}"
user_id_1_ace_regex = /.*\\bob:\(F\)/
user_id_2_ace_regex = /.*\\jerry:\(DENY\)\(M\)/
user_id_3_ace_regex = /.*\\billy:\(R\)/
user_id_4_ace_regex = /.*\\sarah:\(DENY\)\(RX\)/
user_id_5_ace_regex = /.*\\sally:\(W,Rc,X,RA\)/
user_id_6_ace_regex = /.*\\betty:\(DENY\)\(R,W\)/

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

user { "#{user_id_1}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_2}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_3}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_4}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_5}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

user { "#{user_id_6}":
  ensure     => present,
  groups     => 'Users',
  managehome => true,
  password   => "L0v3Pupp3t!"
}

acl { "#{target}":
  permissions  => [
    { identity => '#{user_id_1}', type => 'allow', rights => ['full'] },
    { identity => '#{user_id_2}', type => 'deny', rights => ['modify'] },
    { identity => '#{user_id_3}', type => 'allow', rights => ['read'] },
    { identity => '#{user_id_4}', type => 'deny', rights => ['read','execute'] },
    { identity => '#{user_id_5}', type => 'allow', rights => ['write','execute'] },
    { identity => '#{user_id_6}', type => 'deny', rights => ['write','read'] }
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
    assert_match(user_id_1_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_2_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_3_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_4_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_5_ace_regex, result.stdout, 'Expected ACL was not present!')
    assert_match(user_id_6_ace_regex, result.stdout, 'Expected ACL was not present!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'File content is invalid!')
  end
end
