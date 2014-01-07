# This Source Code Form is subject to the terms of the Mozilla Public
# # License, v. 2.0. If a copy of the MPL was not distributed with this
# # file, You can obtain one at http://mozilla.org/MPL/2.0/.

#This creates the rlocalpath variable for Windows root home directory. This is needed becuase
#on Windows root is a renamed built in account and may not always recieve the typical home directory.

# calculate the root sid once, since it's needed for rlocalpath, too
def get_rsid
    rootsidquery = "select sid from Win32_UserAccount where name = 'root'"
    sidsq = Facter::Util::WMI.execquery(rootsidquery)
    sidsq[0].sid
end

Facter.add("rsid") do
    confine :operatingsystem => :windows
    setcode do
        get_rsid
    end
end

Facter.add("rlocalpath") do
    confine :operatingsystem => :windows
    setcode do
        rootlpquery = "select localpath from Win32_UserProfile where sid = '#{get_rsid}'"
        lpq = Facter::Util::WMI.execquery(rootlpquery)
        for lpobj in lpq do
            result = "#{lpobj.LocalPath}"
        end
        result
    end
end
