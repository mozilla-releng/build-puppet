# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This function is useful in "large" puppetagain clusters.  It takes an
# argument conssiting of a hash with regular expressions as keys, and lists of
# servers as values.  Each hash element represents a group, with the listed
# servers being an equally-weighted set of servers for that group.  The keys
# are matched against agent's fqdn to determine which group(s) contain it.  The
# result is a shuffled list of servers, with the servers in the same group
# listed first.  See manifests/moco-config.pp for an example.  Note that this
# is not required for installations with only server.
module Puppet::Parser::Functions
  newfunction(:sort_servers_by_group, :type => :rvalue, :arity => 1) do |args|
    groups = args[0]
    fqdn = lookupvar('::fqdn')

    group_servers = []
    all_servers = groups.values.flatten
    groups.each_pair do |re, servers|
        group_servers += servers if Regexp.new(re) =~ fqdn
    end

    # shuffle the group servers and then all servers, and run them through uniq so that
    # the group servers come out first.  The random number generator is seeded with the
    # fqdn so that the list differs from host to host, but is the same from one puppet
    # run to the next.  This would be so much easier with Ruby-1.9 :(
    old_seed = rand()
    srand(Digest::MD5.hexdigest([fqdn].join(':')).hex)
    result = (group_servers.shuffle + all_servers.shuffle).uniq
    srand(old_seed)
    result
  end
end
