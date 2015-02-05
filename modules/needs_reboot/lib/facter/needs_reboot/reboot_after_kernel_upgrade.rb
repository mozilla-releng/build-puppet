# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'facter/needs_reboot'

Facter::NeedsReboot.newreason("reboot_after_kernel_upgrade") do
# if file exists and the version string within does not match
# the current running kernel then a reboot is needed
File.exists? '/.kernel_release' and File.open('/.kernel_release', "r").readline != Facter.value(:kernelrelease)

end
