class sudoers::settings {
    include ::shared
    $group = $::shared::root_group
    $owner = "root"
    $mode = "440"
}
