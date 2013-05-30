# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Puppet::Parser::Functions
  newfunction(:assert_aspect, :type => :statement) do |args|
    aspect = args[0]
    message = args[1]
    if not message
      message = "This host must have aspect #{aspect}"
    end
    aspects = lookupvar("aspects")
    (aspects = []) if aspects == :undefined
    raise Puppet::Error, message unless aspects.include? aspect
  end
end

