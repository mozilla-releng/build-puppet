define osxutils::defaults ($domain = undef,
    $key = undef,
    $value = undef,
    $user = 'root') {
    $defaults_cmd = "/usr/bin/defaults"
    if ($domain != undef) and ($key != undef) and ($value != undef) {
        exec {
            "osx_defaults write ${domain} ${key}=>${value}" :
                command =>
                "${defaults_cmd} -currentHost write ${domain} ${key} ${value}",
                unless =>
                "/bin/test x`${defaults_cmd} -currentHost read ${domain} ${key}` = x'${value}'",
                user => $user,
        }
    }
    else {
        warning("Cannot ensure present without domain, key, and value attributes")
    }
}
