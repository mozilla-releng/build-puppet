# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Puppet::Parser::Functions
  newfunction(:filemode, :type => :rvalue, :arity => 1) do |args|
    mode = Integer(args[0])

    # on windows, the group bits always turn out the same as the user bits,
    # so set them that way on input.  See https://projects.puppetlabs.com/issues/22051
    if lookupvar("::operatingsystem") == "windows" then
      mode = (mode & ~0070) | ((mode & 0700) >> 3)
    end
    mode
  end
end
