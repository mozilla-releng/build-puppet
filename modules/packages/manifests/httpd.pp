class packages::httpd {
    case $operatingsystem {
        CentOS: {
           fail("not implemented at this time")
        }
 
        Darwin: {
            # installed by default
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
