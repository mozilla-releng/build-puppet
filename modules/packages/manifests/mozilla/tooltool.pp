class packages::mozilla::tooltool {
    include packages::mozilla::python27
    # this package is simple enough that its source code is embedded in the
    # puppet repo.  It gets the Python intepreter added to its shebang line
    $python = '/tools/python27/bin/python2.7'
    file {
        "/tools/tooltool.py":
            owner => root,
            group => root,
            mode => 0755,
            content => template("packages/tooltool.py");
    }
}
