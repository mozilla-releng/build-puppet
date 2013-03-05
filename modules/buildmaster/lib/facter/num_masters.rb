# num_masters.rb
#
require 'facter'
if FileTest.exists?("/etc/default/buildbot.d")
    Facter.add("num_masters") do
        setcode do
            Facter::Util::Resolution.exec('ls -1 /etc/default/buildbot.d | wc -l')
        end
    end
end
