# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Puppet::Parser::Functions
  newfunction(:has_aspect, :type => :rvalue, :arity => 1) do |args|
    aspect = args[0]
    aspects = lookupvar("aspects")
    aspects = [] if aspects == :undefined
    aspects.include? aspect
  end
end
