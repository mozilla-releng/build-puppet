# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Array of supported OSes
supported_os = ['Darwin', 'Linux']

if supported_os.include? Facter.value(:kernel)
  fqdn = Facter.value(:fqdn)
  openssl_path = Facter::Core::Execution.which('openssl')
  puppet_cert = Facter.value(:puppet_vardir) + "/ssl/certs/" + fqdn + ".pem"
  exec_string = openssl_path + " x509 -noout -in " + puppet_cert + " -"


  # Return the installed puppet agent certificates expiration date in epoch time
  Facter.add(:puppet_agent_cert_enddate) do
    confine :kernel => supported_os
    setcode do
      enddate = Facter::Core::Execution.execute(exec_string + "enddate").split('=')
      extract_date = enddate[1].split(' ')
      extract_time = extract_date[2].split(':')
      epoch_t = Time.utc( extract_date[3], extract_date[0], extract_date[1], extract_time[0], extract_time[1], extract_time[2] ).to_i
      # Return enddate as epoch time
      epoch_t
    end
  end

  # Return the installed puppet agent certificates issuer as fqdn
  Facter.add(:puppet_agent_cert_issuer) do
    confine :kernel => supported_os
    setcode do
      re = Regexp.new('^issuer= /CN=CA on (.+)$')
      issuer = Facter::Core::Execution.execute(exec_string + "issuer").sub(re, '\1')
      # Return fqdn of issuer
      issuer
    end
  end

  # Return the installed puppet agent certificates subject as fqdn
  Facter.add(:puppet_agent_cert_subject) do
    confine :kernel => supported_os
    setcode do
      re = Regexp.new('^subject= /CN=(.+)$')
      subject = Facter::Core::Execution.execute(exec_string + "subject").sub(re, '\1')
      # Return the fqdn of the subject
      subject
    end
  end
end

