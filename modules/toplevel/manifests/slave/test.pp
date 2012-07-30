class toplevel::slave::test inherits toplevel::slave {
    # test slaves need a GUI, and to be logged in.  For now they're just Darwin,
    # so we get the GUI for free and just need to ensure VNC is enabled.
    include vnc
    include screenresolution::talos
    include users::builder::autologin

    include ntp::atboot
}

