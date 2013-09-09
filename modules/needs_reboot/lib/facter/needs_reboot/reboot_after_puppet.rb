# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'facter/needs_reboot'

Facter::NeedsReboot.newreason("reboot_after_puppet") do
  # this is the semaphore file used to indicate to puppetize.sh and puppet::atboot
  # that the host needs to be restarted.
  File.exists? '/REBOOT_AFTER_PUPPET'
end
