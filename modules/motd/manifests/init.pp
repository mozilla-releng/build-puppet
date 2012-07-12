define motd($content, $order=10) {
    include motd::base

    concat::fragment {
        $name:
            target => "/etc/motd",
            content => $content,
            order => $order;
    }
}
