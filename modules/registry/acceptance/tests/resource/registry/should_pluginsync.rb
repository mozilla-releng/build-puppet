require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname + 'lib/systest/util/registry'
# Include our utility methods in the singleton class of the test case instance.
class << self
  include Systest::Util::Registry
end

test_name "Windows Registry Module"

master_manifest_content = <<HERE
notify { 'Hello World!': }
HERE

setup_master master_manifest_content

step "Start the master and test pluginsync" do
  with_master_running_on(master, master_options) do
    windows_agents.each do |agent|
      this_agent_args = agent_args % get_test_file_path(agent, agent_lib_dir)
      run_agent_on(agent, this_agent_args, :acceptable_exit_codes => agent_exit_codes) do
        assert_match(/registry_key/, result.stdout,
                     "Expected that registry_key is present in the output.")
        assert_match(/registry_value/, result.stdout,
                     "Expected that registry_value is present in the output.")
        assert_match(/Hello World/, result.stdout,
                     "Expected that Hello World is in the output.")
        assert_no_match(/already initialized constant/, result.stderr,
                        "Expected that stderr contains no already initialized constant warnings. Is a constant being re-defined?")
      end
    end
  end
end

clean_up
