#
# == How to run this ==
# Please see ReadMe at the top of the repository for instructions on setup and running.
#

$acls = hiera_hash('acls', {})

notify { $acls: }
create_resources(acl, $acls)

$tempAcl = Acl['tempdir']

file {'c:/temp':
  ensure => 'directory',
}
#
#file {'C:/temp':
#  ensure => 'directory',
#}

acl { 'c:\temp':
  permissions => [
    {
      identity => 'Administrators',
      rights   => [full]
    }
  ],
  owner       => 'Administrators',
  inherit_parent_permissions => true
}

acl { 'temp_dir_module_name':
  target      => 'c:/temp',
  permissions => [
    {
      identity => 'bob',
      rights   => [read,execute]
    },
    {
      identity => 'tim',
      rights   => [read,execute]
    }
  ],
}

acl { 'temp_dir_module2_name':
  target      => 'c:/temp',
  permissions => [
    {
      identity => 'bill',
      rights   => [full],
      affects  => self_only
    }
    ,
    {
      identity => 'tim',
      rights   => [read,execute]
    }
  ],
}

$tempAcl2 = Acl['c:/temp']

#pry()
#$foo = inline_template("<% require 'pry';binding.pry %>")
