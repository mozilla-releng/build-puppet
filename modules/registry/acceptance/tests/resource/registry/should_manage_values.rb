require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname + 'lib/systest/util/registry'
# Include our utility methods in the singleton class of the test case instance.
class << self
  include Systest::Util::Registry
end

test_name "Registry Value Management"

# Generate a unique key name
keyname = "PuppetLabsTest_Value_#{randomstring(8)}"
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
  registry_key { '#{keypath}\\SubKey1': }
  registry_key { '#{keypath}\\SubKey2': }
  if $architecture == 'x64' {
    registry_key { '32:#{keypath}': }
    registry_key { '32:#{keypath}\\SubKey1': }
    registry_key { '32:#{keypath}\\SubKey2': }
  }

  # The Default Value
  registry_value { '#{keypath}\\SubKey1\\\\':
    data => "Default Data phase=${::fact_phase}",
  }
  registry_value { '#{keypath}\\SubKey2\\\\':
    type => array,
    data => [ "Default Data L1 phase=${::fact_phase}", "Default Data L2 phase=${::fact_phase}" ],
  }

  # String Values
  registry_value { '#{keypath}\\SubKey1\\ValueString1':
    data => "Should be a string phase=${::fact_phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString2':
    type => string,
    data => "Should be a string phase=${::fact_phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString3':
    ensure => present,
    type   => string,
    data   => "Should be a string phase=${::fact_phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString4':
    data   => "Should be a string phase=${::fact_phase}",
    type   => string,
    ensure => present,
  }

  if $architecture == 'x64' {
    # String Values
    registry_value { '32:#{keypath}\\SubKey1\\ValueString1':
      data => "Should be a string phase=${::fact_phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString2':
      type => string,
      data => "Should be a string phase=${::fact_phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString3':
      ensure => present,
      type   => string,
      data   => "Should be a string phase=${::fact_phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString4':
      data   => "Should be a string phase=${::fact_phase}",
      type   => string,
      ensure => present,
    }
  }

  # Array Values
  registry_value { '#{keypath}\\SubKey1\\ValueArray1':
    type => array,
    data => "Should be an array L1 phase=${::fact_phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray2':
    type => array,
    data => [ "Should be an array L1 phase=${::fact_phase}" ],
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray3':
    type => array,
    data => [ "Should be an array L1 phase=${::fact_phase}",
              "Should be an array L2 phase=${::fact_phase}" ],
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray4':
    ensure => present,
    type   => array,
    data   => [ "Should be an array L1 phase=${::fact_phase}",
                "Should be an array L2 phase=${::fact_phase}" ],
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray5':
    data   => [ "Should be an array L1 phase=${::fact_phase}",
                "Should be an array L2 phase=${::fact_phase}" ],
    type   => array,
    ensure => present,
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray1':
      type => array,
      data => "Should be an array L1 phase=${::fact_phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray2':
      type => array,
      data => [ "Should be an array L1 phase=${::fact_phase}" ],
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray3':
      type => array,
      data => [ "Should be an array L1 phase=${::fact_phase}",
                "Should be an array L2 phase=${::fact_phase}" ],
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray4':
      ensure => present,
      type   => array,
      data   => [ "Should be an array L1 phase=${::fact_phase}",
                  "Should be an array L2 phase=${::fact_phase}" ],
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray5':
      data   => [ "Should be an array L1 phase=${::fact_phase}",
                  "Should be an array L2 phase=${::fact_phase}" ],
      type   => array,
      ensure => present,
    }
  }

  # Expand Values
  registry_value { '#{keypath}\\SubKey1\\ValueExpand1':
    type => expand,
    data => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=${::fact_phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueExpand2':
    type   => expand,
    data   => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=${::fact_phase}",
    ensure => present,
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueExpand1':
      type => expand,
      data => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=${::fact_phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueExpand2':
      type   => expand,
      data   => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=${::fact_phase}",
      ensure => present,
    }
  }

  # DWORD Values
  registry_value { '#{keypath}\\SubKey1\\ValueDword1':
    type => dword,
    data => $::fact_phase,
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueDword1':
      type => dword,
      data => $::fact_phase,
    }
  }

  # QWORD Values
  registry_value { '#{keypath}\\SubKey1\\ValueQword1':
    type => qword,
    data => $::fact_phase,
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueQword1':
      type => qword,
      data => $::fact_phase,
    }
  }

  # Binary Values
  registry_value { '#{keypath}\\SubKey1\\ValueBinary1':
    type => binary,
    data => "0${::fact_phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueBinary2':
    type => binary,
    data => "DE AD BE EF CA F${::fact_phase}"
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueBinary1':
      type => binary,
      data => "0${::fact_phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueBinary2':
      type => binary,
      data => "DEAD BEEF CAF${::fact_phase}"
    }
  }

}

# We always include phase1 because the resources will contain ${::fact_phase}
# which will trigger resource changed event messages we can test against if we
# run "phase 2" twice after phase1 has already been run twice.
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
      x64 = x64?(agent)

      # A set of keys we expect Puppet to create
      phase1_resources_created = [
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\].ensure: created/,
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey2\].ensure: created/,
      ]

      if x64?(agent)
        phase1_resources_created += [
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\].ensure: created/,
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey2\].ensure: created/,
        ]
      end

      # A set of values we expect Puppet to change in Phase 2
      phase2_resources_changed = Array.new

      prefixes = ['']
      prefixes << '32:' if x64

      # This is just to save a whole bunch of copy / paste
      prefixes.each do |prefix|
        # We should have created 4 REG_SZ values
        1.upto(4).each do |idx|
          phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString#{idx}\].ensure: created/
          phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString#{idx}\].data: data changed 'Should be a string phase=1' to 'Should be a string phase=2'/
        end
        # We should have created 5 REG_MULTI_SZ values
        1.upto(5).each do |idx|
          phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueArray#{idx}\].ensure: created/
        end

        # The first two array items are an exception
        1.upto(2).each do |idx|
          phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueArray#{idx}\].data: data changed 'Should be an array L1 phase=1' to 'Should be an array L1 phase=2'/
        end

        # The rest of the array items are OK and have 2 "lines" each.
        3.upto(5).each do |idx|
          phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueArray#{idx}\].data: data changed 'Should be an array L1 phase=1,Should be an array L2 phase=1' to 'Should be an array L1 phase=2,Should be an array L2 phase=2'/
        end

        # We should have created 2 REG_EXPAND_SZ values
        1.upto(2).each do |idx|
          phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueExpand#{idx}\].ensure: created/
          phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueExpand#{idx}\].data: data changed '%SystemRoot% - Should be a REG_EXPAND_SZ phase=1' to '%SystemRoot% - Should be a REG_EXPAND_SZ phase=2'/
        end
        # We should have created 1 qword
        1.upto(1).each do |idx|
          phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueQword#{idx}\].ensure: created/
          phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueQword#{idx}\].data: data changed '1' to '2'/
        end
        # We should have created 1 dword
        1.upto(1).each do |idx|
          phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueDword#{idx}\].ensure: created/
          phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueDword#{idx}\].data: data changed '1' to '2'/
        end
        # We should have created 2 binary values
        1.upto(2).each do |idx|
          phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueBinary#{idx}\].ensure: created/
        end
        # We have different data for the binary values
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueBinary1\].data: data changed '01' to '02'/
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueBinary2\].data: data changed 'de ad be ef ca f1' to 'de ad be ef ca f2'/
      end

      step "Registry Values - Phase 1.a - Create some values"
      on agent, puppet_agent(this_agent_args, :environment => { 'FACTER_FACT_PHASE' => '1' }), :acceptable_exit_codes => agent_exit_codes do
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
        phase1_resources_created.each do |val_re|
          assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
        end
      end

      step "Registry Values - Phase 1.b - Make sure Puppet is idempotent"
      on agent, puppet_agent(this_agent_args, :environment => { 'FACTER_FACT_PHASE' => '1' }), :acceptable_exit_codes => agent_exit_codes do
        phase1_resources_created.each do |val_re|
          assert_no_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
        end
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      end

      step "Registry Values - Phase 2.a - Change some values"
      on agent, puppet_agent(this_agent_args, :environment => { 'FACTER_FACT_PHASE' => '2' }), :acceptable_exit_codes => agent_exit_codes do
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
        phase2_resources_changed.each do |val_re|
          assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
        end
      end

      step "Registry Values - Phase 2.b - Make sure Puppet is idempotent"
      on agent, puppet_agent(this_agent_args, :environment => { 'FACTER_FACT_PHASE' => '2' }), :acceptable_exit_codes => agent_exit_codes do
        phase2_resources_changed.each do |val_re|
          assert_no_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
        end
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      end

      step "Registry Values - Phase 3 - Check the default value (#14572)"
      # (#14572) This test uses the 'native' version of reg.exe to read the
      # default value of a registry key.  It should contain the string shown in
      # val_re.
      dir = native_sysdir(agent)
      if not dir
        Log.warn("Cannot query 64-bit view of registry from 32-bit process, skipping")
      else
        on agent, "#{dir}/reg.exe query '#{keypath}\\Subkey1'" do
          val_re = /\(Default\)    REG_SZ    Default Data phase=2/i
          assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
        end
      end
    end
  end
end
