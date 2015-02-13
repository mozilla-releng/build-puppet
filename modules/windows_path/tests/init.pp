include windows_path

# (This test assumes, that C:\Windows\system32 is in your path. If that is not
#  the case, replace directory with something that is in your path.)
windows_path {'Test: Do not duplicate a path entry that is already present':
  ensure      => present,
  directory   => 'C:\Windows\system32',
}
->
windows_path {'Test: Add a path entry if it is not present':
  ensure      => present,
  directory   => 'C:\this\should\be\added',
}
->
# (For this test to do the right thing (actually remove a path entry, you would
#  need to add the given entry to your path manually before.)
windows_path {'Test: Remove an existing path entry':
  ensure      => absent,
  directory   => 'C:\some\path\that\should\be\removed',
}
->
windows_path {'Test: Do nothing when removing a path entry that is not present':
  ensure      => absent,
  directory   => 'C:\nothing\to\do',
}
->
# Test namevar
windows_path {'C:\add\this\also\please':
  ensure      => present,
}
