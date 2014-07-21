require 'puppet/type'
begin
  require "puppet_x/puppetlabs/registry"
  require "puppet_x/puppetlabs/registry/provider_base"
rescue LoadError => detail
  require "pathname" # JJM WORK_AROUND #14073 and #7788
  module_base = Pathname.new(__FILE__).dirname + "../../../"
  require module_base + "puppet_x/puppetlabs/registry"
  require module_base + "puppet_x/puppetlabs/registry/provider_base"
end

Puppet::Type.type(:registry_value).provide(:registry) do
  include PuppetX::Puppetlabs::Registry::ProviderBase

  defaultfor :operatingsystem => :windows
  confine    :operatingsystem => :windows

  def self.instances
    []
  end

  def exists?
    Puppet.debug("Checking the existence of registry value: #{self}")
    found = false
    begin
      hive.open(subkey, Win32::Registry::KEY_READ | access) do |reg|
        type = [0].pack('L')
        size = [0].pack('L')
        found = reg_query_value_ex_a.call(reg.hkey, valuename, 0, type, 0, size) == 0
      end
    rescue Win32::Registry::Error => detail
      case detail.code
      when 2
        # Code 2 is the error message for "The system cannot find the file specified."
        # http://msdn.microsoft.com/en-us/library/windows/desktop/ms681382.aspx
        found = false
      else
        error = Puppet::Error.new("Unexpected exception from Win32 API. detail: (#{detail.message}) ERROR CODE: #{detail.code}. Puppet Error ID: D4B679E4-0E22-48D5-80EF-96AAEC0282B9")
        error.set_backtrace detail.backtrace
        raise error
      end
    end
    found
  end

  def create
    Puppet.debug("Creating registry value: #{self}")
    write_value
  end

  def flush
    # REVISIT - This concept of flush seems different than package provider's
    # concept of flush.
    Puppet.debug("Flushing registry value: #{self}")
    return if resource[:ensure] == :absent
    write_value
  end

  def destroy
    Puppet.debug("Destroying registry value: #{self}")
    hive.open(subkey, Win32::Registry::KEY_ALL_ACCESS | access) do |reg|
      reg.delete_value(valuename)
    end
  end

  def type
    regvalue[:type] || :absent
  end

  def type=(value)
    regvalue[:type] = value
  end

  def data
    regvalue[:data] || :absent
  end

  def data=(value)
    regvalue[:data] = value
  end

  def regvalue
    unless @regvalue
      @regvalue = {}
      hive.open(subkey, Win32::Registry::KEY_READ | access) do |reg|
        type = [0].pack('L')
        size = [0].pack('L')

        if reg_query_value_ex_a.call(reg.hkey, valuename, 0, type, 0, size) == 0
          @regvalue[:type], @regvalue[:data] = from_native(reg.read(valuename))
        end
      end
    end
    @regvalue
  end

  # convert puppet type and data to native
  def to_native(ptype, pdata)
    # JJM Because the data property is set to :array_matching => :all we
    # should always get an array from Puppet.  We need to convert this
    # array to something usable by the Win API.
    raise Puppet::Error, "Data should be an Array (ErrorID 37D9BBAB-52E8-4A7C-9F2E-D7BF16A59050)" unless pdata.kind_of?(Array)
    ndata =
      case ptype
      when :binary
        pdata.first.scan(/[a-f\d]{2}/i).map{ |byte| [byte].pack('H2') }.join('')
      when :array
        # We already have an array, and the native API write method takes an
        # array, so send it thru.
        pdata
      else
        # Since we have an array, take the first element and send it to the
        # native API which is expecting a scalar.
        pdata.first
      end

    return [name2type(ptype), ndata]
  end

  # convert from native type and data to puppet
  def from_native(ary)
    ntype, ndata = ary

    pdata =
      case type2name(ntype)
      when :binary
        ndata.scan(/./).map{ |byte| byte.unpack('H2')[0]}.join(' ')
      when :array
        # We get the data from the registry in Array form.
        ndata
      else
        ndata
      end

    # JJM Since the data property is set to :array_matching => all we should
    # always give an array to Puppet.  This is why we have the ternary operator
    # I'm not calling .to_a because Ruby issues a warning about the default
    # implementation of to_a going away in the future.
    return [type2name(ntype), pdata.kind_of?(Array) ? pdata : [pdata]]
  end

  def reg_query_value_ex_a
    self.class.reg_query_value_ex_a
  end

  def self.reg_query_value_ex_a
    @reg_query_value_ex_a ||= Win32API.new('advapi32', 'RegQueryValueEx', 'LPLPPP', 'L')
  end

  private

  def write_value
    begin
      hive.open(subkey, Win32::Registry::KEY_ALL_ACCESS | access) do |reg|
        ary = to_native(resource[:type], resource[:data])
        reg.write(valuename, ary[0], ary[1])
      end
    rescue Win32::Registry::Error => detail
      error = case detail.code
      when 2
        # Code 2 is the error message for "The system cannot find the file specified."
        # http://msdn.microsoft.com/en-us/library/windows/desktop/ms681382.aspx
        Puppet::Error.new("Cannot write to the registry. The parent key does not exist. detail: (#{detail.message}) Puppet Error ID: AC99C7C6-98D6-4E91-A75E-970F4064BF95")
      else
        Puppet::Error.new("Unexpected exception from Win32 API. detail: (#{detail.message}). ERROR CODE: #{detail.code}. Puppet Error ID: F46C6AE2-C711-48F9-86D6-5D50E1988E48")
      end
      error.set_backtrace detail.backtrace
      raise error
    end
  end

  def path
    @path ||= PuppetX::Puppetlabs::Registry::RegistryValuePath.new(resource.parameter(:path).value)
  end
end
