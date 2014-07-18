# This module is meant to be mixed into the registry_key AND registry_value providers.
module PuppetX
module Puppetlabs
module Registry
module ProviderBase
  # This is a class method in order to be easily mocked in the spec tests.
  def self.initialize_system_api
    if Puppet.features.microsoft_windows?
      begin
        require 'win32/registry'
      rescue LoadError => exc
        msg = "Could not load the required win32/registry library (ErrorID 1EAD86E3-D533-4286-BFCB-CCE8B818DDEA) [#{exc.message}]"
        Puppet.err msg
        error = Puppet::Error.new(msg)
        error.set_backtrace exc.backtrace
        raise error
      end
    end
  end

  def self.included(base)
    # Initialize the Win32 API.  This is a method call so the spec tests can
    # easily mock the initialization of the Win32 libraries on non-win32
    # systems.
    initialize_system_api

    # Define an hkeys class method in the eigenclass we're being mixed into.
    # This is the one true place to define the root hives we support.
    class << base
      def hkeys
        # REVISIT: I'd like to make this easier to mock and stub.
        {
          :hkcr => Win32::Registry::HKEY_CLASSES_ROOT,
          :hklm => Win32::Registry::HKEY_LOCAL_MACHINE,
        }
      end
    end
  end

  # The rest of these methods will be mixed in as instance methods into the
  # provider class.  The path method is expected to be mixed in by the provider
  # specific module, ProviderKeyBase or ProviderValueBase
  def hkeys
    self.class.hkeys
  end

  def hive
    hkeys[path.root]
  end

  def access
    path.access
  end

  def root
    path.root
  end

  def subkey
    path.subkey
  end

  def valuename
    path.valuename
  end

  def type2name_map
    {
      Win32::Registry::REG_NONE      => :none,
      Win32::Registry::REG_SZ        => :string,
      Win32::Registry::REG_EXPAND_SZ => :expand,
      Win32::Registry::REG_BINARY    => :binary,
      Win32::Registry::REG_DWORD     => :dword,
      Win32::Registry::REG_QWORD     => :qword,
      Win32::Registry::REG_MULTI_SZ  => :array
    }
  end

  def type2name(type)
    type2name_map[type]
  end

  def name2type(name)
    name2type = {}
    type2name_map.each_pair {|k,v| name2type[v] = k}
    name2type[name]
  end
end
end
end
end
