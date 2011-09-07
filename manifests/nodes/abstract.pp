# This file defines the hierarchy of base node types.

# every node inherits from 'base'
node "base" {
    include puppet
    include packages::setup
}

node "slave" inherits "base" {
    #include puppet::atboot
}

# servers (non-slaves, really) inherit from 'server'
node "server" inherits "base" {
    include puppet::periodic
}
