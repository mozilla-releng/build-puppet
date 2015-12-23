# lint:ignore:autoloader_layout
class { 'one': }

# two should be applied
assert { 'This should succeed':
  condition => true
} ->
class { 'two': }

# three should not be applied
assert { 'This should fail':
  condition => $::non_existant_fact
} ->
class { 'three': }

# four should be applied
assert { 'This should be skipped due to ensure => absent':
  ensure => absent,
  condition => $::non_existant_fact
} ->
class { 'four': }



class one {
  notify { 'this is a test': }
}

class two {
  notify { 'this is from the second class': }
}

class three {
  notify { 'this is from the third class': }
}

class four {
  notify { 'this is from the fourth class': }
}
# lint:endignore