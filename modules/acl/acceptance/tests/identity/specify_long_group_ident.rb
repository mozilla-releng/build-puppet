test_name 'Windows ACL Module - Specify Group with Long Name for Identity'

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = 'c:/temp/specify_long_group_ident.txt'
#256 Characters
group_id = 'nzxncvkjnzxjkcnvkjzxncvkjznxckjvnzxkjncvzxnvckjnzxkjcnvkjzxncvkjzxncvkjzxncvkjnzxkjcnvkzjxncvkjzxnvckjnzxkjcvnzxkncjvjkzxncvkjzxnvckjnzxjkcvnzxkjncvkjzxncvjkzxncvkjzxnkvcjnzxjkcvnkzxjncvkjzxncvkzckjvnzxkcvnjzxjkcnvzjxkncvkjzxnvkjsdnjkvnzxkjcnvkjznvkjxcbvzs'

file_content = 'Pretty little poodle dressed in noodles.'
verify_content_command = "cat /cygdrive/c/temp/specify_long_group_ident.txt"
file_content_regex = /\A#{file_content}\z/

verify_acl_command = "icacls #{target}"
acl_regex = /.*\\nzxncvkjnzxjkcnvkjzxncvkjznxckjvnzxkjncvzxnvckjnzxkjcnvkjzxncvkjzxncvkjzxncvkjnzxkjcnvkzjxncvkjzxnvckjnzxkjcvnzxkncjvjkzxncvkjzxnvckjnzxjkcvnzxkjncvkjzxncvjkzxncvkjzxnkvcjnzxjkcvnkzxjncvkjzxncvkzckjvnzxkcvnjzxjkcnvzjxkncvkjzxnvkjsdnjkvnzxkjcnvkjznvkjxcbvzs:\(F\)/

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

group { '#{group_id}':
  ensure => present,
}

acl { '#{target}':
  permissions  => [
    { identity => '#{group_id}', rights => ['full'] },
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
