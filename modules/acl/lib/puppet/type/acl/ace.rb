require 'puppet/parameter/value_collection'
require 'pathname'

class Puppet::Type::Acl
  # Ace is an Access Control Entry for use with the Access
  # Control List (ACL) type. ACEs contain information about
  # the trustee, the rights, and on some systems how they are
  # inherited and propagated to subtypes.
  class Ace < Hash
    # < Hash is due to a bug with how Puppet::Resource.to_manifest
    # does not work through quite the same code and needs to
    # believe this custom object is a Hash. If issues are later
    # found, this should be reviewed.
    require Pathname.new(__FILE__).dirname + '../../../' + 'puppet/type/acl/rights'

    attr_reader :identity
    attr_reader :rights
    attr_reader :type
    attr_reader :child_types
    attr_reader :affects
    attr_reader :is_inherited
    attr_reader :mask

    def initialize(permission_hash, provider = nil)
      @provider = provider
      id = permission_hash['identity']
      id = permission_hash['id'] if id.nil? || id.empty?
      self.identity = id
      self.id = permission_hash['id']
      @mask = permission_hash['mask']
      self.rights = permission_hash['rights']
      self.type = permission_hash['type']
      self.child_types = permission_hash['child_types']
      self.affects = permission_hash['affects']
      @is_inherited = permission_hash['is_inherited'] || false
      @hash = nil
    end

    def validate(value,*allowed_values)
      validator = Puppet::Parameter::ValueCollection.new
      validator.newvalues(*allowed_values)
      validator.validate(value)

      value
    end

    def is_inherited?
      return is_inherited
    end

    def convert_to_symbol(value)
      return nil if (value.nil? || value.empty?)
      return value if value.is_a?(Symbol)

      value.downcase.to_sym
    end

    def validate_non_empty(name,value)
      if value.nil? or value == ''
        raise ArgumentError, "A non-empty #{name} must be specified."
      end
      if value.kind_of?(Array) and value.count == 0
        raise ArgumentError, "Value for #{name} should have least one element in the array."
      end

      value
    end

    def validate_array(name,values)
      raise ArgumentError, "Value for #{name} should be an array. Perhaps try ['#{values}']?" unless values.kind_of?(Array)

      values
    end

    def validate_individual_values(values,*allowed_values)
      values.each do |value|
        validate(value,*allowed_values)
      end

      values
    end

    def convert_to_symbols(values)
      value_syms = []
      values.each do |value|
        value_syms << convert_to_symbol(value)
      end

      value_syms
    end

    def convert_from_symbols(symbols)
      values = []
      symbols.each do |value|
        values << value.to_s
      end

      values
    end

    def ensure_rights_order
      @rights.sort_by! { |r| Puppet::Type::Acl::Rights.new(r).order }
    end

    def ensure_rights_values_compatible
      if @rights.include?(:mask_specific) && rights.count != 1
        raise ArgumentError, "In each ace, when specifying rights, if you include 'mask_specific', it should be without anything else e.g. rights => ['mask_specific']. Please decide whether 'mask_specific' or predetermined rights and correct the manifest. Reference: #{self.inspect}"
      end

      if @rights.include?(:full) && rights.count != 1
        Puppet.warning("In each ace, when specifying rights, if you include 'full', it should be without anything else e.g. rights => ['full']. Please remove the extraneous rights from the manifest to remove this warning. Reference: #{self.inspect}")
        @rights = [:full]
      end
      if @rights.include?(:modify) && rights.count != 1
        Puppet.warning("In each ace, when specifying rights, if you include 'modify', it should be without anything else e.g. rights => ['modify']. Please remove the extraneous rights from the manifest to remove this warning. Reference: #{self.inspect}")
        @rights = [:modify]
      end
    end

    def ensure_mask_when_mask_specific
      if @rights.include?(:mask_specific) && (@mask.nil? || @mask.empty?)
        raise ArgumentError, "If you specify rights => ['mask_specific'], you must also include mask => 'value'. Reference: #{self.inspect}"
      end
    end

    def ensure_unique_values(values)
      if values.kind_of?(Array)
        return values.uniq
      end

      values
    end

    def ensure_none_or_self_only_sync
      return if @child_types.nil? ||@affects.nil?
      return if @child_types == :none && @affects == :self_only
      return unless @child_types == :none || @affects == :self_only

      if @child_types == :none && (@affects != :all && @affects != :self_only)
        Puppet.warning("If child_types => 'none', affects => value will be ignored. Please remove affects or set affects => 'self_only' to remove this warning. Reference: #{self.inspect}")
      end
      @affects = :self_only if @child_types == :none

      if @affects == :self_only && (@child_types != :all && @child_types != :none)
        Puppet.warning("If affects => 'self_only', child_types => value will be ignored. Please remove child_types or set child_types => 'none' to remove this warning. Reference: #{self.inspect}")
      end
      @child_types = :none if @affects == :self_only
    end

    def identity=(value)
      @identity = validate_non_empty('identity', value)
      @hash = nil
    end

    def id
      if @id.nil? || @id.empty?
        if @identity && @provider && @provider.respond_to?(:get_account_id)
          @id = @provider.get_account_id(@identity)
        end
      end

      @id
    end

    def id=(value)
      @id = value
      @hash = nil
    end

    def rights=(value)
      @rights = ensure_unique_values(
          convert_to_symbols(
          validate_individual_values(
          validate_array(
               'rights',
               validate_non_empty('rights', value)
          ),
          :full, :modify, :write, :read, :execute, :mask_specific)))
      ensure_rights_order
      ensure_rights_values_compatible
      ensure_mask_when_mask_specific if @rights.include?(:mask_specific)
      @hash = nil
    end

    def mask=(value)
      @mask = value
      @hash = nil
    end

    def type=(value)
      @type = convert_to_symbol(validate(value || :allow, :allow, :deny))
      @hash = nil
    end

    def child_types=(value)
      @child_types = convert_to_symbol(validate(value || :all, :all, :objects, :containers, :none))
      ensure_none_or_self_only_sync
      @hash = nil
    end

    def affects=(value)
      @affects = convert_to_symbol(validate(value || :all, :all, :self_only, :children_only, :self_and_direct_children_only, :direct_children_only))
      ensure_none_or_self_only_sync
      @hash = nil
    end

    def get_comparison_ids(other = nil)
      ignore_other = true
      id_has_value = false
      other_id_has_value = false
      other_id = nil

      unless other.nil?
        ignore_other = false
        other_id_has_value = true unless other.id.nil? || other.id.empty?
      end

      id_has_value = true unless self.id.nil? || self.id.empty?

      if id_has_value && (ignore_other || other_id_has_value)
        id = self.id
        other_id = other.id unless ignore_other
      else
        if @provider && @provider.respond_to?(:get_account_name)
          id = @provider.get_account_name(@identity)
          other_id = @provider.get_account_name(other.identity) unless ignore_other
        else
          id = @identity
          other_id = other.identity unless ignore_other
        end
      end

      [id, other_id]
    end

    # This ensures we are looking at the same ace even if the
    # rights are different. Contextually we have two ace objects
    # and we are trying to determine if they are the same ace or
    # different given all of the different compare points.
    #
    # @param other [Ace] The ace that we are comparing to.
    # @return [Boolean] true if all points are equal
    def same?(other)
      return false unless other.is_a?(Ace)

      account_ids = get_comparison_ids(other)

      return account_ids[0] == account_ids[1] &&
          @child_types == other.child_types &&
          @affects == other.affects &&
          @is_inherited == other.is_inherited &&
          @type == other.type
    end

    # This ensures we are looking at the same ace with the same
    # rights. We want to know if the two aces are equal on all
    # important data points.
    #
    # @param other [Ace] The ace that we are comparing to.
    # @return [Boolean] true if all points are equal
    def ==(other)
      return false unless other.is_a?(Ace)

      return same?(other) &&
             @rights == other.rights
    end
    alias_method :eql?, :==

    def hash
      return get_comparison_ids[0].hash ^
             @rights.hash ^
             @type.hash ^
             @child_types.hash ^
             @affects.hash ^
             @is_inherited.hash
    end

    def to_hash
      return @hash if @hash

      ace_hash = Hash.new
      ace_hash['identity'] = identity
      ace_hash['rights'] = convert_from_symbols(rights)
      ace_hash['mask'] = mask if (rights == [:mask_specific] && !mask.nil?)
      ace_hash['type'] = type unless (type == :allow || type.nil?)
      ace_hash['child_types'] = child_types unless (child_types == :all || child_types == :none || child_types.nil?)
      ace_hash['affects'] = affects unless (affects == :all || affects.nil?)
      ace_hash['is_inherited'] = is_inherited if is_inherited

      @hash = ace_hash
      @hash
    end

    # The following methods: keys, values, [](key) make
    # `puppet resource acl somelocation` believe that
    # this is actually a Hash and can pull the values
    # from this object.
    def keys
      to_hash.keys
    end

    def values
      to_hash.values
    end

    def [](key)
      to_hash[key]
    end

    def inspect
      hash = to_hash
      return_value = hash.keys.collect do |key|
        key_value = hash[key]
        if key_value.is_a? Array
          "#{key} => #{key_value}"
        else
          "#{key} => '#{key_value}'"
        end
      end.join(', ')

      "\n { #{return_value} }"
    end
    alias_method :to_s, :inspect
  end
end
