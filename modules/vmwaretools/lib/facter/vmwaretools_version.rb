# Fact written by janorn
# Reference: https://github.com/janorn/puppet-vmwaretools/blob/master/lib/facter/vmwaretools.rb

require 'facter'

Facter.add(:vmwaretools_version) do
  confine :virtual => :vmware
  setcode do
    if File::executable?("/usr/bin/vmware-toolbox-cmd")
      Facter::Util::Resolution.exec("/usr/bin/vmware-toolbox-cmd -v").sub(%r{(\d*\.\d*\.\d*)\.\d*\s+\(build(-\d*)\)},'\1\2')
    else
      "not installed"
    end
  end
end
