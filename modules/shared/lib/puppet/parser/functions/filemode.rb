# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Puppet::Parser::Functions
  newfunction(:filemode, :type => :rvalue, :arity => 1) do |args|
    mode = Integer(args[0])

    # on windows, we just don't manage file permissions with mode bits.  It doesn't work.
    if lookupvar("::operatingsystem") == "windows" then
        :undef
    else
        args[0]
        end
      end
    end
