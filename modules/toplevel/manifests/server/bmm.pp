# mobile-services are servers that host support services for mobile devices
# such as the mobile re-imaging software (Black Mobile Magic)

class toplevel::server::bmm inherits toplevel::server {
    include ::blackmobilemagic
}

