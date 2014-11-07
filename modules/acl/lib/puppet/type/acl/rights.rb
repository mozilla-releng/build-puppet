class Puppet::Type::Acl

  class Rights
    attr_reader :value
    attr_reader :order

    def initialize(permission)
      return if permission.nil? || permission.empty?
      @value = permission.downcase.to_sym unless @value.is_a?(Symbol)

      @order = case @value
         when :full
           0
         when :modify
           1
         when :write
           2
         when :read
           3
         when :execute
           4
         when :mask_specific
           5
       end
    end
  end
end
