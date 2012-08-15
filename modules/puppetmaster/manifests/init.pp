class puppetmaster {
    include puppetmaster::install
    include puppetmaster::config
    include puppetmaster::service
    include puppetmaster::sync_data
    include puppetmaster::update_crl
}
