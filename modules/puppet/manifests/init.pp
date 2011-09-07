# Upgrade and configure puppet.  Note that the puppet startup is deferred to
# puppet::atboot and puppet::periodic; the former is used for slaves, while
# other systems run the latter.
class puppet {
    include puppet::install
}
