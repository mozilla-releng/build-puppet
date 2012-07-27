class toplevel::slave::test inherits toplevel::slave {
    # test slaves need to login so we can run graphical processes as a user
    include users::builder::autologin
    include ntp::atboot
}

