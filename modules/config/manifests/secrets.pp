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
    $builder_pw_vnc_base64 = extlookup("builder_pw_vnc_base64")
    $mozpool_inventory_url = extlookup("mozpool_inventory_url")
    $mozpool_inventory_username = extlookup("mozpool_inventory_username")
    $mozpool_inventory_password = extlookup("mozpool_inventory_password")
    $mozpool_db_hostname = extlookup("mozpool_db_hostname")
    $mozpool_db_username = extlookup("mozpool_db_username")
    $mozpool_db_password = extlookup("mozpool_db_password")
    $mozpool_db_database = extlookup("mozpool_db_database")
    $mozpool_staging_db_hostname = extlookup("mozpool_staging_db_hostname")
    $mozpool_staging_db_username = extlookup("mozpool_staging_db_username")
    $mozpool_staging_db_password = extlookup("mozpool_staging_db_password")
    $mozpool_staging_db_database = extlookup("mozpool_staging_db_database")
}
