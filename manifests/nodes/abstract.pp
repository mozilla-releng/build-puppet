# This file defines the hierarchy of base node types.

# every node inherits from 'base'
node "base" {
    include puppet
}

# buildslaves inherit from 'slave'
node "slave" inherits "base" {
}

# servers (non-slaves, really) inherit from 'server'
node "server" inherits "base" {
}
