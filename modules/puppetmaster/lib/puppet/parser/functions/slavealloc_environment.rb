# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This function takes the calculated slave trustlevel and the
# slavealloc-defined environment, and looks up the appropriate keyset in the
# given map.
#
# args: $fqdn - host's fqdn, from $clientcert
#               NOTE: slavealloc is keyed by hostname, not fqdn
module Puppet::Parser::Functions
  newfunction(:slavealloc_environment, :type => :rvalue, :arity => 1) do |args|
    fqdn = args[0]

    # convert fqdn to hostname by chopping the first atom off; this introduces yet
    # more untrustworthiness into slavealloc, since we're not keying by fqdn.
    fqdn =~ /^([^.]*)\./
    hostname = $1

    slavealloc_slaves = function_hiera(['slavealloc_slaves', {}])
    if ! slavealloc_slaves.has_key? hostname
      Puppet.warning("#{hostname.inspect} not found in slavealloc data; defaulting environment to 'none'")
      'none'
    else
      slave_info = slavealloc_slaves[hostname]
      slave_info['environment']
    end
  end
end
