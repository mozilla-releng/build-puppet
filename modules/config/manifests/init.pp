# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Config
# if you add a new key here, add it to the wiki as well!

# We use config rather than settings because "settings" is a magic class
class config {
    include config::secrets
    
    $puppet_notif_email = extlookup("puppet_notif_email")
    $puppet_server = extlookup("puppet_server")
    $yum_server = extlookup("yum_server")
    $builder_username = extlookup("builder_username")
}
