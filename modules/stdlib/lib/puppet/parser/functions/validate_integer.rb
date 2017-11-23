#
# validate_interger.rb
#
# Ported to Puppet 3.7 from https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/lib/puppet/parser/functions/validate_integer.rb
module Puppet::Parser::Functions
  newfunction(:validate_integer) do |args|

    # tell the user we need at least one, and optionally up to two other parameters
    raise Puppet::ParseError, "validate_integer(): Wrong number of arguments; must be 1, 2 or 3, got #{args.length}" unless !args.empty? && args.length < 4

    input, max, min = *args

    # check maximum parameter
    if args.length > 1
      max = max.to_s
      # allow max to be empty (or undefined) if we have a minimum set
      if args.length > 2 && max == ''
        max = nil
      else
        begin
          max = Integer(max)
        rescue TypeError, ArgumentError
          raise Puppet::ParseError, "validate_integer(): Expected second argument to be unset or an Integer, got #{max}:#{max.class}"
        end
      end
    else
      max = nil
    end

    # check minimum parameter
    if args.length > 2
      begin
        min = Integer(min.to_s)
      rescue TypeError, ArgumentError
        raise Puppet::ParseError, "validate_integer(): Expected third argument to be unset or an Integer, got #{min}:#{min.class}"
      end
    else
      min = nil
    end

    # ensure that min < max
    if min && max && min > max
      raise Puppet::ParseError, "validate_integer(): Expected second argument to be larger than third argument, got #{max} < #{min}"
    end

    # create lamba validator function
    # Original, Ruby >=1.9
    # validator = ->(num) do
    # Reworked for Ruby 1.8:
    validator = lambda do |num|
      # check input < max
      if max && num > max
        raise Puppet::ParseError, "validate_integer(): Expected #{input.inspect} to be smaller or equal to #{max}, got #{input.inspect}."
      end
      # check input > min (this will only be checked if no exception has been raised before)
      if min && num < min
        raise Puppet::ParseError, "validate_integer(): Expected #{input.inspect} to be greater or equal to #{min}, got #{input.inspect}."
      end
    end

    # if this is an array, handle it.
    case input
    when Array
      # check every element of the array
      input.each_with_index do |arg, pos|
        begin
          raise TypeError if arg.is_a?(Hash)
          arg = Integer(arg.to_s)
          validator.call(arg)
        rescue TypeError, ArgumentError
          raise Puppet::ParseError, "validate_integer(): Expected element at array position #{pos} to be an Integer, got #{arg.class}"
        end
      end
    # for the sake of compatibility with ruby 1.8, we need extra handling of hashes
    when Hash
      raise Puppet::ParseError, "validate_integer(): Expected first argument to be an Integer or Array, got #{input.class}"
    # check the input. this will also fail any stuff other than pure, shiny integers
    else
      begin
        input = Integer(input.to_s)
        validator.call(input)
      rescue TypeError, ArgumentError
        raise Puppet::ParseError, "validate_integer(): Expected first argument to be an Integer or Array, got #{input.class}"
      end
    end
  end
end
