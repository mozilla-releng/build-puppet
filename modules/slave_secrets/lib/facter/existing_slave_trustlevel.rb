# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'puppet'

# this reads the *existing* slave trustlevel, if any, from disk on the slave.
# init.pp uses this to detect slaves that are not reimaged when they change
# trustlevel.  It's intended to prevent mistakes, not as a security mechanism:
# it is trivially easy for agents to fake facts.
Facter.add(:existing_slave_trustlevel) do
  setcode do
    filename = "/etc/slave-trustlevel"
    if File.exists?(filename)
      File.read(filename).chomp
    end
  end
end
