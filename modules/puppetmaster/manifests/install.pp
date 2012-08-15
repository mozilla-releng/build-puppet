class puppetmaster::install {
    include packages::httpd
    include packages::mod_ssl
    include packages::mod_passenger
    include packages::puppetserver
}
