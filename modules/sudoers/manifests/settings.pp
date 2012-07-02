class sudoers::settings {
    $group = $operatingsystem ? {
        Darwin => wheel,
        default => root
    }
    $owner = "root"
    $mode = "440"
}
