# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# set up Facter::NeedsReboot to track our reasons for rebooting

module Facter
  module NeedsReboot
    def self.reasons
      unless defined?(@reasons)
        @reasons = {}
      end
      @reasons
    end

    def self.load_all()
      # load each ruby file in needs_reboot
      basedir = File.join(File.dirname(__FILE__), 'needs_reboot')
      Dir.glob("#{basedir}/*.rb").each do |fn|
        load fn
      end
    end

    def self.newreason(method, &block)
      reasons[method] = block
    end
  end
end

Facter::NeedsReboot.load_all

# one summary 'needs_reboot' fact
Facter.add("needs_reboot") do
  setcode do
    current_reasons = Facter::NeedsReboot.reasons.select { |m, p| p.call }.map { |m, p| m }
    current_reasons.sort.join(', ') if current_reasons != []
  end
end

# and facts for each reason
Facter::NeedsReboot.reasons.each do |m, p|
  Facter.add("needs_reboot_for_#{m}") do
    setcode do
      p.call
    end
  end
end

