class sudoers::settings {
    include ::shared
    $group = $users::root::group
    $owner = $users::root::username
    $mode = "440"
}
