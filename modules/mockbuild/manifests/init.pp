class mockbuild {
    include packages::mozilla::mock_mozilla
    file {
        "/etc/mock_mozilla/mozilla-f16-i386.cfg":
            require => Class["packages::mozilla::mock_mozilla"],
            source => "puppet:///modules/mockbuild/mozilla-f16-i386.cfg";
        "/etc/mock_mozilla/mozilla-centos6-i386.cfg":
            require => Class["packages::mozilla::mock_mozilla"],
            source => "puppet:///modules/mockbuild/mozilla-centos6-i386.cfg";
        "/etc/mock_mozilla/mozilla-centos6-x86_64.cfg":
            require => Class["packages::mozilla::mock_mozilla"],
            source => "puppet:///modules/mockbuild/mozilla-centos6-x86_64.cfg";
    }
}
