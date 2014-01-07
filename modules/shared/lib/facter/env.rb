# This Source Code Form is subject to the terms of the Mozilla Public
# # License, v. 2.0. If a copy of the MPL was not distributed with this
# # file, You can obtain one at http://mozilla.org/MPL/2.0/.

#This fact enable OS enviroment variables support in Puppet.
#This may come in handy for Windows' paths and staying consistent across GPO, MDT, and Puppet.

ENV.each do |k,v|
    Facter.add("env_#{k.downcase}".to_sym) do
        setcode do
            v
        end
    end
end
