class pushapkworker::mime_types {

    case $::operatingsystem {
        CentOS: {
            file { '/etc/mime.types':
                mode        => '0644',
                content     => 'application/vnd.android.package-archive     apk',
            }
        }
        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
