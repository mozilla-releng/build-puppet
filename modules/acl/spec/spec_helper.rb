require 'puppetlabs_spec_helper/module_spec_helper'
require 'pathname'
require 'tmpdir'
require 'fileutils'

if Puppet.features.microsoft_windows?
  require 'puppet/util/windows/security'

  def take_ownership(path)
    path = path.gsub('/', '\\')
    output = %x(takeown.exe /F #{path} /R /A /D Y 2>&1)
    if $? != 0 #check if the child process exited cleanly.
      puts "#{path} got error #{output}"
    end
  end
end

RSpec.configure do |config|
  tmpdir = Dir.mktmpdir("rspecrun_acl")
  oldtmpdir = Dir.tmpdir()
  ENV['TMPDIR'] = tmpdir

  if Puppet::Util::Platform.windows?
    config.output_stream = $stdout
    config.error_stream = $stderr
    config.formatters.each { |f| f.instance_variable_set(:@output, $stdout) }
  end

  #config.before :each do
  #  # Disabling garbage collection inside each test, and only running it at
  #  # the end of each block, gives us an ~ 15 percent speedup, and more on
  #  # some platforms *cough* windows *cough* that are a little slower.
  #  GC.disable
  #end
  #
  #config.after :each do
  #  # This will perform a GC between tests, but only if actually required.  We
  #  # experimented with forcing a GC run, and that was less efficient than
  #  # just letting it run all the time.
  #  GC.enable
  #end

  config.after :suite do
    # return to original tmpdir
    ENV['TMPDIR'] = oldtmpdir
    if Puppet::Util::Platform.windows?
      take_ownership(tmpdir)
    end
    FileUtils.rm_rf(tmpdir)
  end
end

# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias :must :should
  alias :must_not :should_not
end
