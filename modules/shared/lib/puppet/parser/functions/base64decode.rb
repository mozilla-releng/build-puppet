require 'base64'

module Puppet::Parser::Functions
  newfunction(:base64decode, :type => :rvalue) do |args|
    Base64.decode64 args[0]
  end
end
