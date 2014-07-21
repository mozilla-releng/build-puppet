require 'tempfile'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname + 'lib/systest/util/registry'
# Include our utility methods in the singleton class of the test case instance.
class << self
  include Systest::Util::Registry
end

test_name "Registry Key Management"

# Generate a unique key name
keyname = "PuppetLabsTest_#{randomstring(8)}"
# This is the keypath we'll use for this entire test.  We will actually create this key and delete it.
keypath = "HKLM\\Software\\Vendor\\#{keyname}"

master_manifest_content = <<HERE
notify { fact_phase: message => "fact_phase: $fact_phase" }

registry_key { 'HKLM\\Software\\Vendor': ensure => present }

# Setup keys to purge
class phase1 {
  Registry_key { ensure => present }
  Registry_value { ensure => present, data => 'Puppet Default Data' }

  registry_key { '#{keypath}': }
  registry_key { '#{keypath}\\SubKey1': }

  if $architecture == 'x64' {
    registry_key { '32:#{keypath}': }
    registry_key { '32:#{keypath}\\SubKey1': }
  }

  registry_key   { '#{keypath}\\SubKeyToPurge': }
  registry_value { '#{keypath}\\SubKeyToPurge\\Value1': }
  registry_value { '#{keypath}\\SubKeyToPurge\\Value2': }
  registry_value { '#{keypath}\\SubKeyToPurge\\Value3': }

  if $architecture == 'x64' {
    registry_key   { '32:#{keypath}\\SubKeyToPurge': }
    registry_value { '32:#{keypath}\\SubKeyToPurge\\Value1': }
    registry_value { '32:#{keypath}\\SubKeyToPurge\\Value2': }
    registry_value { '32:#{keypath}\\SubKeyToPurge\\Value3': }
  }
}

# Purge the keys in a subsequent run
class phase2 {
  Registry_key { ensure => present, purge_values => true }

  registry_key { '#{keypath}\\SubKeyToPurge': }
  if $architecture == 'x64' {
    registry_key { '32:#{keypath}\\SubKeyToPurge': }
  }
}

# Delete our keys
class phase3 {
  Registry_key { ensure => absent }

  # These have relationships because autorequire break things when
  # ensure is absent.  REVISIT: Make this not a requirement.
  # REVISIT: This appears to work with explicit relationships but not with ->
  # notation.
  registry_key { '#{keypath}\\SubKey1': }
  registry_key { '#{keypath}\\SubKeyToPurge': }
  registry_key { '#{keypath}':
    require => Registry_key['#{keypath}\\SubKeyToPurge', '#{keypath}\\SubKey1'],
  }

  if $architecture == 'x64' {
    registry_key { '32:#{keypath}\\SubKey1': }
    registry_key { '32:#{keypath}\\SubKeyToPurge': }
    registry_key { '32:#{keypath}':
      require => Registry_key['32:#{keypath}\\SubKeyToPurge', '32:#{keypath}\\SubKey1'],
    }
  }
}

case $fact_phase {
      '2': { include phase2 }
      '3': { include phase3 }
  default: { include phase1 }
}
HERE

# Setup the master to use the modules specified in the --modules option
setup_master master_manifest_content

step "Start the master" do
  with_master_running_on(master, master_options) do
    # A set of keys we expect Puppet to create
    keys_created_native = [
      /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
      /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\].ensure: created/
    ]

    keys_created_wow = [
     /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
     /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\].ensure: created/
    ]

    # A set of regular expression of values to be purged in phase 2.
    values_purged_native = [
      /Registry_value\[hklm.Software.Vendor.PuppetLabsTest\w+.SubKeyToPurge.Value1\].ensure: removed/,
      /Registry_value\[hklm.Software.Vendor.PuppetLabsTest\w+.SubKeyToPurge.Value2\].ensure: removed/,
      /Registry_value\[hklm.Software.Vendor.PuppetLabsTest\w+.SubKeyToPurge.Value3\].ensure: removed/
    ]

    values_purged_wow = [
      /Registry_value\[32:hklm.Software.Vendor.PuppetLabsTest\w+.SubKeyToPurge.Value1\].ensure: removed/,
      /Registry_value\[32:hklm.Software.Vendor.PuppetLabsTest\w+.SubKeyToPurge.Value2\].ensure: removed/,
      /Registry_value\[32:hklm.Software.Vendor.PuppetLabsTest\w+.SubKeyToPurge.Value3\].ensure: removed/
    ]

    windows_agents.each do |agent|
      this_agent_args = agent_args % get_test_file_path(agent, agent_lib_dir)
      is_x64 = x64?(agent)

      keys_created  = keys_created_native  + (is_x64 ? keys_created_wow : [])
      values_purged = values_purged_native + (is_x64 ? values_purged_wow : [])

      # Do the first run and make sure the key gets created.
      step "Registry - Phase 1.a - Create some keys"
      run_agent_on(agent, this_agent_args, :acceptable_exit_codes => agent_exit_codes) do
        keys_created.each do |key_re|
          assert_match(key_re, result.stdout,
                       "Expected #{key_re.inspect} to match the output. (First Run)")
        end
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      end

      step "Registry - Phase 1.b - Make sure Puppet is idempotent"
      # Do a second run and make sure the key isn't created a second time.
      run_agent_on(agent, this_agent_args, :acceptable_exit_codes => agent_exit_codes) do
        keys_created.each do |key_re|
          assert_no_match(key_re, result.stdout,
                       "Expected #{key_re.inspect} NOT to match the output. (First Run)")
        end
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      end

      step "Registry - Phase 2 - Make sure purge_values works"
      on agent, puppet_agent(this_agent_args, :environment => { 'FACTER_FACT_PHASE' => '2' }),
        :acceptable_exit_codes => agent_exit_codes do
        values_purged.each do |val_re|
          assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
        end
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      end

      step "Registry - Phase 3 - Clean up"
      on agent, puppet_agent(this_agent_args, :environment => { 'FACTER_FACT_PHASE' => '3' }),
        :acceptable_exit_codes => agent_exit_codes do
        assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      end
    end
  end
end

clean_up
