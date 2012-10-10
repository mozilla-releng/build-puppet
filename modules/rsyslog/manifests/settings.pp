class rsyslog::settings {
    include ::shared
    include users::root
    $group = $users::root::group
    $owner = $users::root::username
    $mode = "644"
}

