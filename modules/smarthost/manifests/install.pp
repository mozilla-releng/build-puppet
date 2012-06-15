class smarthost::install {
  package { [ "postfix", "mailx" ]:
    ensure => present,
  }
}
