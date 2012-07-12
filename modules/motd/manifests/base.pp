class motd::base {
    include concat::setup

    $group = $operatingsystem ? {
        Darwin => wheel,
        default => root
    }
    concat {
        "/etc/motd":
            owner => root,
            group => $group,
            mode => 0644;
    }
}
