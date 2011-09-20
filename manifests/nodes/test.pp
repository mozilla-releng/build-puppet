node "relabs-win.build.mtv1.mozilla.com" {
    notify {
        "hello":
            message => "This is your windows box on puppet.";
    }
}

