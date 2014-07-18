require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname + 'lib/systest/util/registry'
# Include our utility methods in the singleton class of the test case instance.
class << self
  include Systest::Util::Registry
end

test_name "Registry Value Management (Mixed Case)"

# JJM - The whole purpose of this test is to exercise situations where the user
# specifies registry valies in a case-insensitive but case-preserving way.
# This has particular "gotchas" with regard to autorequire.
#
# Note how SUBKEY1 is capitalized in some resources but downcased in other
# resources.  On windows these refer to the same thing, and case is preserved.
# In puppet, however, resource namevars are case sensisitve unless otherwise
# noted.

# Generate a unique key name
keyname = "PuppetLabsTest_MixedCase_#{randomstring(8)}"
# This is the keypath we'll use for this entire test.  We will actually create this key and delete it.
vendor_path = "HKLM\\Software\\Vendor"
keypath = "#{vendor_path}\\#{keyname}"

master_manifest_content = <<HERE
notify { fact_phase: message => "fact_phase: $fact_phase" }

registry_key { '#{vendor_path}': ensure => present }
if $architecture == 'x64' {
  registry_key { '32:#{vendor_path}': ensure => present }
}

class phase1 {
  Registry_key { ensure => present }
  registry_key { '#{keypath}': }
  registry_key { '#{keypath}\\SUBKEY1': }
  # NOTE THE DIFFERENCE IN CASE IN SubKey1 and SUBKEY1 above
  registry_key { '#{keypath}\\SubKey1\\SUBKEY2': }
  if $architecture == 'x64' {
    registry_key { '32:#{keypath}': }
    registry_key { '32:#{keypath}\\SUBKEY1': }
    registry_key { '32:#{keypath}\\SubKey1\\SUBKEY2': }
  }

  # The Default Value
  # NOTE THE DIFFERENCE IN CASE IN SubKey1 and SUBKEY1 above
  registry_value { '#{keypath}\\SubKey1\\\\':
    data => "Default Data",
  }

  # String Values
  registry_value { '#{keypath}\\SubKey1\\ValueString1':
    data => "Should be a string",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString2':
    type => string,
    data => "Should be a string",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString3':
    ensure => present,
    type   => string,
    data   => "Should be a string",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString4':
    data   => "Should be a string",
    type   => string,
    ensure => present,
  }
  registry_value { '#{keypath}\\SubKey1\\SubKey2\\ValueString1':
    data => "Should be a string",
  }
  registry_value { '#{keypath}\\SubKey1\\SubKey2\\ValueString2':
    type => string,
    data => "Should be a string",
  }
  registry_value { '#{keypath}\\SubKey1\\SubKey2\\ValueString3':
    ensure => present,
    type   => string,
    data   => "Should be a string",
  }
  registry_value { '#{keypath}\\SubKey1\\SubKey2\\ValueString4':
    data   => "Should be a string",
    type   => string,
    ensure => present,
  }

  # The Default Value
  # NOTE THE DIFFERENCE IN CASE IN SubKey1 and SUBKEY1 above
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\\\':
      data => "Default Data",
    }
    # String Values
    registry_value { '32:#{keypath}\\SubKey1\\ValueString1':
      data => "Should be a string",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString2':
      type => string,
      data => "Should be a string",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString3':
      ensure => present,
      type   => string,
      data   => "Should be a string",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString4':
      data   => "Should be a string",
      type   => string,
      ensure => present,
    }
    registry_value { '32:#{keypath}\\SubKey1\\SubKey2\\ValueString1':
      data => "Should be a string",
    }
    registry_value { '32:#{keypath}\\SubKey1\\SubKey2\\ValueString2':
      type => string,
      data => "Should be a string",
    }
    registry_value { '32:#{keypath}\\SubKey1\\SubKey2\\ValueString3':
      ensure => present,
      type   => string,
      data   => "Should be a string",
    }
    registry_value { '32:#{keypath}\\SubKey1\\SubKey2\\ValueString4':
      data   => "Should be a string",
      type   => string,
      ensure => present,
    }
  }
}

case $fact_phase {
  default: { include phase1 }
}
HERE

# Setup the master to use the modules specified in the --modules option
setup_master master_manifest_content

step "Start the master" do
  with_master_running_on(master, master_options) do
    windows_agents.each do |agent|
      this_agent_args = agent_args % get_test_file_path(agent, agent_lib_dir)

      # A set of keys we expect Puppet to create
      phase1_resources_created = [
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SUBKEY1\].ensure: created/,
        /Registry_value\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\\\\].ensure: created/,
        /Registry_value\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString1\].ensure: created/,
        /Registry_value\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString2\].ensure: created/,
        /Registry_value\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString3\].ensure: created/,
        /Registry_value\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString4\].ensure: created/,
      ]

      if x64?(agent)
        phase1_resources_created += [
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\\SUBKEY1\].ensure: created/,
        ]
      end

      step "Registry Tolerate Mixed Case Values - Phase 1.a - Create some values"
      on agent, puppet_agent(this_agent_args, :environment => { 'FACTER_FACT_PHASE' => '1' }), :acceptable_exit_codes => agent_exit_codes do
        phase1_resources_created.each do |val_re|
          assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
        end
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      end
    end
  end
end
