# Fact written by janorn
# Reference: https://github.com/janorn/puppet-vmwaretools/blob/master/lib/facter/vmwaretools.rb

require 'facter'

Facter.add(:supermicro_ipmi_version) do
  confine :boardmanufacturer => :Supermicro
  confine :boardproductname => [:X8SIT, :X8SIL]
  setcode do
    version = ''
    if File::executable?("/usr/bin/ipmitool")
      output = Facter::Util::Resolution.exec("/usr/bin/ipmitool mc info 2>/dev/null")
      output and output.split('\n').each do |line|
        if line =~ /^Firmware Revision *: *([0-9.]+)$/
          version = $1.strip
          break
        end
      end
    end
    version
  end
end
