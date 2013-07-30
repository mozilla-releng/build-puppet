# == Fact: concat_ruby_interpreter
#
# A custom fact that reveals the path to the ruby intepreter
#
require 'rbconfig'
Facter.add("concat_ruby_interpreter") do
  setcode do
    (File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["RUBY_INSTALL_NAME"]) +
     RbConfig::CONFIG["EXEEXT"])
  end
end
