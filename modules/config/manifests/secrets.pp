# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Secrets
# if you add a new key here, add it to the wiki as well!
class config::secrets {
    $root_pw_hash = extlookup("root_pw_hash")
    $root_pw_pbkdf2 = extlookup("root_pw_pbkdf2")
    $root_pw_pbkdf2_salt = extlookup("root_pw_pbkdf2_salt")
    $root_pw_pbkdf2_iterations = extlookup("root_pw_pbkdf2_iterations")
    $builder_pw_hash = extlookup("builder_pw_hash")
    $builder_pw_pbkdf2 = extlookup("builder_pw_pbkdf2")
    $builder_pw_pbkdf2_salt = extlookup("builder_pw_pbkdf2_salt")
    $builder_pw_pbkdf2_iterations = extlookup("builder_pw_pbkdf2_iterations")
    $builder_pw_kcpassword_base64 = extlookup("builder_pw_kcpassword_base64")
    $bmm_inventory_url = extlookup("bmm_inventory_url")
    $bmm_inventory_username = extlookup("bmm_inventory_username")
    $bmm_inventory_password = extlookup("bmm_inventory_password")
    $bmm_db_url = extlookup("bmm_db_url")
}
