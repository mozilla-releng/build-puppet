require 'puppet/type'
require 'pathname'

Puppet::Type.newtype(:acl) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/acl/ace'

  @doc = <<-'EOT'
    Manages access control lists (ACLs).  The `acl` type is
    typically used when you need more complex management of
    permissions e.g. Windows. ACLs typically contain access
    control entries (ACEs) that define a trustee (identity)
    with a set of rights, whether the type is allow or deny,
    and how inheritance and propagation of those ACEs are
    applied to the resource target and child types under it.
    The order that ACEs are listed in is important on Windows
    as it determines what is applied first.

    Order of ACE application on Windows is explicit deny,
    explicit allow, inherited deny, then inherited allow. You
    cannot specify inherited ACEs in a manifest, only whether
    to allow upstream inheritance to flow into the managed
    target location (known as security descriptor). Please
    ensure your modeled resources follow this order or Windows
    will complain. NOTE: `acl` type does not enforce or
    complain about ACE order.

    For very specific examples, see the readme[1] and learn
    about the different features of the `acl` type.

    [1] https://github.com/puppetlabs/puppetlabs-acl/blob/master/README.md

    **Autorequires:** If Puppet is managing the user, group or
    target of an acl resource, the acl type will autorequire
    them.

    At a minimum, you need to provide the target and at least
    one permission (access control entry or ACE). It will default
    the other settings to sensible defaults.

    Minimally expressed sample usage:

      acl { 'c:/tempperms':
        permissions => [
         { identity => 'Administrator', rights => ['full'] },
         { identity => 'Users', rights => ['read','execute'] }
       ],
      }

    If you want you can provide a fully expressed ACL. The
    fully expressed acl in the sample below produces the same
    settings as the minimal sample above.

    Fully expressed sample usage:

      acl { 'c:/tempperms':
        target      => 'c:/tempperms',
        target_type => 'file',
        purge       => 'false',
        permissions => [
         { identity => 'Administrator', rights => ['full'], type=> 'allow', child_types => 'all', affects => 'all' },
         { identity => 'Users', rights => ['read','execute'], type=> 'allow', child_types => 'all', affects => 'all' }
        ],
        owner       => 'Administrators', #Creator_Owner specific, doesn't manage unless specified
        group       => 'Users', #Creator_Group specific, doesn't manage unless specified
        inherit_parent_permissions => 'true',
      }

    You can manage the same target across multiple acl
    resources with some caveats. The title of the resource
    needs to be unique. It is suggested that you only do
    this when you would need to (can get confusing). You should
    not set purge => 'true' on any of the resources that apply
    to the same target or you will see thrashing in reports as
    the permissions will be added and removed every catalog
    application. Use this feature with care.

    Manage same ACL resource multiple acls sample usage:

      acl { 'c:/tempperms':
        permissions => [
         { identity => 'Administrator', rights => ['full'] }
       ],
      }

      acl { 'tempperms_Users':
        target      => 'c:/tempperms',
        permissions => [
         { identity => 'Users', rights => ['read','execute'] }
       ],
      }

    Removing upstream inheritance with purge sample usage:

      acl { 'c:/tempperms':
        purge       => 'true',
        permissions => [
         { identity => 'Administrators', rights => ['full'] },
         { identity => 'Users', rights => ['full'] }
        ],
        inherit_parent_permissions => 'false',
      }

     Warning: While managing ACLs you could lock the user running
     Puppet completely out of managing resources using
     purge => 'true' with inherit_parent_permissions => 'false'.
     If Puppet is locked out of managing the resource, manual
     intervention on affected nodes will be required.

  EOT

  feature :ace_order_required, "The provider determines if the order of access control entries (ACE) is required."
  feature :can_inherit_parent_permissions, "The provider can inherit permissions from the parent."

  def initialize(*args)
    super

    # if target is unset, use the title
    if self[:target].nil? then
      self[:target] = self[:name]
    end
  end

  newparam(:name) do
    desc "The name of the acl resource. Used for uniqueness. Will set
      the target to this value if target is unset."

    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty name must be specified."
      end
    end

    isnamevar
  end

  newparam(:target) do
    desc "The location the acl resource is pointing to. In the first
      release of ACL, this will be a file system location.
      The default is the name."

    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty target must be specified."
      end
    end
  end

  newparam(:target_type) do
    desc "The type of target for the Acl resource. In the first release
      of ACL, only `file` is allowed. Defaults to `file`."
    newvalues(:file)
    defaultto(:file)
  end

  newparam(:purge) do
    desc "Purge specifies whether to remove other explicit permissions
      if not specified in the permissions set. This doesn't do anything
      with permissions inherited from parents (to remove those you should
      combine `purge => 'false', inherit_parent_permissions => 'false'` -
      be VERY careful in doing so, you could lock out Puppet from
      managing the resource and manual intervention will be required).
      This also allows you to ensure the permissions listed are not on
      the ACL with `purge => listed_permissions`.
      The default is `false`."
    newvalues(:true, :false, :listed_permissions)
    defaultto(:false)
  end

  newproperty(:permissions, :array_matching => :all) do
    desc "Permissions is an array containing Access Control Entries
      (ACEs). Certain Operating Systems require these ACEs to be in
      explicit order (Windows). Every element in the array is a hash
      that will at the very least need `identity` and `rights` e.g
      `{ identity => 'Administrators', rights => ['full'] }` and at the
      very most can include `type`, `child_types`, `affects`, and
      `mask` (mask should only be specified be with
      `rights => ['mask_specific']`) e.g. `{ identity => 'Administrators',
      rights => ['full'], type=> 'allow', child_types => 'all',
      affects => 'all' }`.

      `identity` is a group, user or ID (SID on Windows). The identity must
      exist on the system and will auto-require on user and group resources.
      This can be in the form of:

        1. User - e.g. `'Bob'` or `'TheNet\\Bob'`
        2. Group e.g. `'Administrators'` or `'BUILTIN\\Administrators'`
        3. SID (Security ID) e.g. `'S-1-5-18'`.

      `rights` is an array that contains `'full'`, `'modify'`,
      `'mask_specific'` or some combination of `'write'`, `'read'`, and
      `'execute'`. If you specify `'mask_specific'` you must also specify
      `mask` with an integer (passed as a string) that represents the
      permissions mask. It is the numeric representation of the binary
      flags.

      `type` is represented as `'allow'` (default) or `'deny'`.

      `child_types` determines how an ACE is inherited downstream from the
      target. Valid values are `'all'` (default), `'objects'`, `'containers'`
      or `'none'`.

      `affects` determines how the downstream inheritance is propagated.
      Valid values are `'all'` (default), `'self_only'`, `'children_only'`,
      `'self_and_direct_children_only'` or `'direct_children_only'`.

      Each permission (ACE) is determined to be unique based on
      identity, type, child_types, and affects. While you can technically
      create more than one ACE that differs from other ACEs only in rights,
      acl module is not able to tell the difference between those so it
      will appear that the resource is out of sync every run when it is not.

      While you will see `is_inherited => 'true'` when running
      puppet resource acl path, puppet will not be able to manage the
      inherited permissions so those will need to be removed if using
      that to build a manifest."

    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, "A non-empty permissions must be specified."
      end
      if value['is_inherited']
        raise ArgumentError,
         "Puppet can not manage inherited ACEs.
         If you used puppet resource acl to build your manifest, please remove
         any is_inherited => true entries in permissions when adding the resource
         to the manifest.
         Reference: #{value.inspect}"
      end
    end

    munge do |permission|
      Puppet::Type::Acl::Ace.new(permission, provider)
    end

    def insync?(current)
      if provider.respond_to?(:permissions_insync?)
        return provider.permissions_insync?(current, @should)
      end

      super(current)
    end

    def is_to_s(currentvalue)
      if provider.respond_to?(:permissions_to_s)
        return provider.permissions_to_s(currentvalue)
      end

      super(currentvalue)
    end

    def should_to_s(shouldvalue)
      if provider.respond_to?(:permissions_should_to_s)
        return provider.permissions_should_to_s(shouldvalue)
      elsif provider.respond_to?(:permissions_to_s)
        return provider.permissions_to_s(shouldvalue)
      end

      super(shouldvalue)
    end

    def self.format_value_for_display(value)
      if value.is_a? Array
        formatted_values = value.collect {|value| format_value_for_display(value)}.join(', ')
        "[#{formatted_values}\n]"
      elsif value.is_a? Puppet::Type::Acl::Ace
        "#{value.inspect}"
      elsif value.is_a? Hash
        hash = value.keys.sort {|a,b| a.to_s <=> b.to_s}.collect do |k|
          "#{k} => #{format_value_for_display(value[k])}"
        end.join(', ')

        "\n { #{hash} }"
      else
        "'#{value}'"
      end
    end
  end

  newproperty(:owner) do
    desc "The owner identity is also known as a trustee or principal
      that is said to own the particular acl/security descriptor. This
      can be in the form of:

       1. User - e.g. `'Bob'` or `'TheNet\\Bob'`
       2. Group e.g. `'Administrators'` or `'BUILTIN\\Administrators'`
       3. SID (Security ID) e.g. `'S-1-5-18'`.

      Defaults to not specified on Windows. This allows owner to stay set
      to whatever it is currently set to (owner can vary depending on the
      original CREATOR OWNER). The trustee must exist on the system and
      will auto-require on user and group resources."

    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, "A non-empty owner must be specified."
      end
    end

    def insync?(current)
      return true if should.nil?

      if provider.respond_to?(:owner_insync?)
        return provider.owner_insync?(current, should)
      end

      super(current)
    end

    def is_to_s(currentvalue)
      if provider.respond_to?(:owner_to_s)
        return provider.owner_to_s(currentvalue)
      end

      super(currentvalue)
    end
    alias :should_to_s :is_to_s
  end

  newproperty(:group) do
    desc "The group identity is also known as a trustee or principal
      that is said to have access to the particular acl/security descriptor.
      This can be in the form of:

       1. User - e.g. `'Bob'` or `'TheNet\\Bob'`
       2. Group e.g. `'Administrators'` or `'BUILTIN\\Administrators'`
       3. SID (Security ID) e.g. `'S-1-5-18'`.

      Defaults to not specified on Windows. This allows group to stay set
      to whatever it is currently set to (group can vary depending on the
      original CREATOR GROUP). The trustee must exist on the system and
      will auto-require on user and group resources."

    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, "A non-empty group must be specified."
      end
    end

    def insync?(current)
      return true if should.nil?

      if provider.respond_to?(:group_insync?)
        return provider.group_insync?(current, should)
      end

      super(current)
    end

    def is_to_s(currentvalue)
      if provider.respond_to?(:group_to_s)
        return provider.group_to_s(currentvalue)
      end

      super(currentvalue)
    end
    alias :should_to_s :is_to_s
  end

  newproperty(:inherit_parent_permissions, :boolean => true, :required_features=> :can_inherit_parent_permissions) do
    desc "Inherit Parent Permissions specifies whether to inherit
      permissions from parent ACLs or not. The default is `true`."
    newvalues(:true,:false)
    defaultto(true)

    def insync?(current)
      super(resource.munge_boolean(current))
    end
  end

  validate do
    if self[:permissions] == []
      raise ArgumentError, "Value for permissions should be an array with at least one element specified."
    end

    if provider.respond_to?(:validate)
      provider.validate
    end
  end

  autorequire(:file) do
    required_file = []
    if self[:target] && self[:target_type] == :file
      target_path = File.expand_path(self[:target]).to_s

      # There is a bug with the casing on the volume (c:/ versus C:/)
      #  causing resources to not be found by the catalog checking
      #  against lowercase and uppercase corrects that.
      target_path[0] = target_path[0].downcase
      unless file_resource = catalog.resource(:file, target_path)
        target_path[0] = target_path[0].upcase
        file_resource = catalog.resource(:file, target_path)
      end
      required_file << file_resource.to_s if file_resource
    end

    required_file
  end

  autorequire(:user) do
    required_users = []

    if provider.respond_to?(:get_account_name)
      has_account_name_method = true
    else
      has_account_name_method = false
    end

    if self[:owner]
      if has_account_name_method
        required_users << "User[#{provider.get_account_name(self[:owner])}]"
      end

      # add the unqualified item whether qualified is found or not
      required_users << "User[#{self[:owner]}]"
    end

    if self[:group]
      if has_account_name_method
        required_users << "User[#{provider.get_account_name(self[:group])}]"
      end

      # add the unqualified item whether qualified is found or not
      required_users << "User[#{self[:group]}]"
    end

    permissions = self[:permissions]
    unless permissions.nil?
      permissions.each do |permission|
        if has_account_name_method
          required_users << "User[#{provider.get_account_name(permission.identity)}]"
        end
        required_users << "User[#{permission.identity}]"
      end
    end

    required_users.uniq
  end

  autorequire(:group) do
    required_groups = []

    if provider.respond_to?(:get_group_name)
      has_account_group_method = true
    else
      has_account_group_method = false
    end

    if self[:owner]
      if has_account_group_method
        required_groups << "Group[#{provider.get_group_name(self[:owner])}]"
      end

      # add the unqualified item whether qualified is found or not
      required_groups << "Group[#{self[:owner]}]"
    end

    if self[:group]
      if has_account_group_method
        required_groups << "Group[#{provider.get_group_name(self[:group])}]"
      end

      # add the unqualified item whether qualified is found or not
      required_groups << "Group[#{self[:group]}]"
    end

    permissions = self[:permissions]
    unless permissions.nil?
      permissions.each do |permission|
        if has_account_group_method
          required_groups << "Group[#{provider.get_group_name(permission.identity)}]"
        end
        required_groups << "Group[#{permission.identity}]"
      end
    end

    required_groups.uniq
  end

  def munge_boolean(value)
    case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
      else
        fail("munge_boolean only takes booleans")
    end
  end
end
