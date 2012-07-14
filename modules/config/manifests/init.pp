# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Config
# if you add a new key here, add it to the wiki as well!

# We use config rather than settings because "settings" is a magic class
class config {
    include config::secrets
    
    $puppet_notif_email = extlookup("puppet_notif_email")
    $puppet_server = extlookup("puppet_server")
    $data_server = extlookup("data_server")
    $data_servers = extlookup("data_servers")
    $puppet_servers = extlookup("puppet_servers")
    $builder_username = extlookup("builder_username")
    $nrpe_allowed_hosts = extlookup("nrpe_allowed_hosts")
    $ntp_server = extlookup("ntp_server")
    $relay_domains = extlookup("relay_domains")
    $ganglia_config_class = extlookup("ganglia_config_class", "")
}
