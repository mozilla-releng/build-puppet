require 'pathname'

class Puppet::Provider::Acl
  module Windows
    # This provides the detailed implementation details for the
    # provider and should shield the provider from legacy
    # support implementations that would happen here.
    module Base
      if Puppet::Util::Platform.windows?
        require Pathname.new(__FILE__).dirname + '../../../../' + 'puppet/type/acl/ace'
        require 'puppet/util/windows/security'
        require 'win32/security'

        # fixes come after everything else is loaded
        require Pathname.new(__FILE__).dirname + '../../../../' + 'puppet/util/monkey_patches'

        REFRESH_SD        = true
        DO_NOT_REFRESH_SD = false

        GENERIC_ALL                  = 0x10000000
        GENERIC_WRITE                = 0x40000000
        GENERIC_READ                 = 0x80000000
        GENERIC_EXECUTE              = 0x20000000
        DELETE                       = 0x00010000

        SYNCHRONIZE                 = 0x100000
        STANDARD_RIGHTS_REQUIRED    = 0xf0000
        STANDARD_RIGHTS_READ        = 0x20000
        STANDARD_RIGHTS_WRITE       = 0x20000
        STANDARD_RIGHTS_EXECUTE     = 0x20000

        FILE_READ_DATA               = 1
        FILE_WRITE_DATA              = 2
        FILE_APPEND_DATA             = 4
        FILE_READ_EA                 = 8
        FILE_WRITE_EA                = 16
        FILE_EXECUTE                 = 32
        FILE_DELETE_CHILD            = 64
        FILE_READ_ATTRIBUTES         = 128
        FILE_WRITE_ATTRIBUTES        = 256

        FILE_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0x1FF

        FILE_GENERIC_READ =
           STANDARD_RIGHTS_READ |
           FILE_READ_DATA |
           FILE_READ_ATTRIBUTES |
           FILE_READ_EA |
           SYNCHRONIZE

        FILE_GENERIC_WRITE =
           STANDARD_RIGHTS_WRITE |
           FILE_WRITE_DATA |
           FILE_WRITE_ATTRIBUTES |
           FILE_WRITE_EA |
           FILE_APPEND_DATA |
           SYNCHRONIZE

        FILE_GENERIC_EXECUTE =
           STANDARD_RIGHTS_EXECUTE |
           FILE_READ_ATTRIBUTES |
           FILE_EXECUTE |
           SYNCHRONIZE

        @security_descriptor = nil

        # Puppet 3.7 deprecated methods at old locations in favor of SID class
        def name_to_sid(name)
          if Puppet::Util::Windows::SID.respond_to?(:name_to_sid)
            Puppet::Util::Windows::SID.name_to_sid(name)
          else
            Puppet::Util::Windows::Security.name_to_sid(name)
          end
        end

        def sid_to_name(value)
          if Puppet::Util::Windows::SID.respond_to?(:sid_to_name)
            Puppet::Util::Windows::SID.sid_to_name(value)
          else
            Puppet::Util::Windows::Security.sid_to_name(value)
          end
        end

        def valid_sid?(string_sid)
          if Puppet::Util::Windows::SID.respond_to?(:valid_sid?)
            Puppet::Util::Windows::SID.valid_sid?(string_sid)
          else
            Puppet::Util::Windows::Security.valid_sid?(string_sid)
          end
        end

        def get_current_permissions
          sd = get_security_descriptor(DO_NOT_REFRESH_SD)
          permissions = []
          permissions if sd.nil? || sd.dacl.nil?

          sd.dacl.each do |ace|
            permissions << Puppet::Type::Acl::Ace.new(convert_to_permissions_hash(ace), self)
          end

          permissions
        end

        def convert_to_permissions_hash(ace)
          return {} if ace.nil?

          sid = ace.sid
          identity = sid_to_name(sid)
          rights = get_ace_rights_from_mask(ace)
          ace_type = get_ace_type(ace)
          child_types = get_ace_child_types(ace)
          affects = get_ace_propagation(ace)
          is_inherited = ace.inherited?
          hash = {'identity'=>"#{identity}", 'id'=>"#{sid}", 'rights'=>rights,
                  'type'=>ace_type, 'child_types'=> child_types,
                  'affects'=>affects, 'is_inherited'=>is_inherited,
                  'mask'=>"#{ace.mask}" }

          hash
        end

        def get_ace_rights_from_mask(ace)
          #todo v2 check that this is a file type and respond appropriately
          rights = []
          return rights if ace.nil?
          mask_specific_remainder = ace.mask

          # full
          if (ace.mask & GENERIC_ALL) == GENERIC_ALL ||
             (ace.mask & FILE_ALL_ACCESS) == FILE_ALL_ACCESS
            rights << :full
            mask_specific_remainder = 0
          end

          if rights == []
            if (ace.mask & FILE_GENERIC_WRITE) == FILE_GENERIC_WRITE
              rights << :write
              mask_specific_remainder &= ~FILE_GENERIC_WRITE
            end
            if (ace.mask & GENERIC_WRITE) == GENERIC_WRITE
              rights << :write
              mask_specific_remainder &= ~GENERIC_WRITE
            end

            if (ace.mask & FILE_GENERIC_READ) == FILE_GENERIC_READ
              rights << :read
              mask_specific_remainder &= ~FILE_GENERIC_READ
            end
            if (ace.mask & GENERIC_READ) == GENERIC_READ
              rights << :read
              mask_specific_remainder &= ~GENERIC_READ
            end

            if (ace.mask & FILE_GENERIC_EXECUTE) == FILE_GENERIC_EXECUTE
              rights << :execute
              mask_specific_remainder &= ~FILE_GENERIC_EXECUTE
            end
            if (ace.mask & GENERIC_EXECUTE) == GENERIC_EXECUTE
              rights << :execute
              mask_specific_remainder &= ~GENERIC_EXECUTE
            end
          end

          # modify
          # if the rights appending changes above, we'll
          # need to ensure this check is still good
          if rights == [:write,:read,:execute] &&
            (ace.mask & DELETE) == DELETE
            rights = [:modify]
            mask_specific_remainder &= ~DELETE
          end

          # rights are too specific, use mask
          if rights == []
            rights << :mask_specific
          elsif mask_specific_remainder != 0
            Puppet.debug("Remainder from #{ace.mask} is #{mask_specific_remainder}")
            rights = [:mask_specific]
          end

          rights
        end
        module_function :get_ace_rights_from_mask

        def get_ace_type(ace)
          return :allow if ace.nil?

          ace_type = case ace.type
            when Puppet::Util::Windows::AccessControlEntry::ACCESS_ALLOWED_ACE_TYPE then :allow
            when Puppet::Util::Windows::AccessControlEntry::ACCESS_DENIED_ACE_TYPE then :deny
          end

          ace_type
        end
        module_function :get_ace_type

        def get_ace_child_types(ace)
          return :all if ace.nil?

          # the order is on purpose
          child_types = :none
          child_types = :objects if ace.object_inherit?
          child_types = :containers if ace.container_inherit?
          child_types = :all if ace.object_inherit? && ace.container_inherit?

          child_types
        end
        module_function :get_ace_child_types

        def get_ace_propagation(ace)
          # http://msdn.microsoft.com/en-us/library/ms229747.aspx
          return :all if ace.nil?

          targets_self = true unless ace.inherit_only?
          targets_children = true if ace.object_inherit? || ace.container_inherit?
          targets_children_only = true if ace.inherit_only?

          # the order is on purpose
          affects = :self_only if targets_self
          affects = :children_only if targets_children_only
          affects = :all if targets_self && targets_children

          # Puppet::Util::Windows::AccessControlEntry defines the propagation flag but doesn't provide a method
          # http://msdn.microsoft.com/en-us/library/windows/desktop/ms692524(v=vs.85).aspx
          no_propagate_flag = 0x4
          propagate = ace.flags & no_propagate_flag != no_propagate_flag
          unless propagate
            affects = :self_and_direct_children_only if targets_self && targets_children
            affects = :direct_children_only if targets_children_only
          end

          affects
        end
        module_function :get_ace_propagation

        def are_permissions_insync?(current_permissions, specified_permissions, purge_value = :false)
          return false if current_permissions.nil? && !specified_permissions.nil? && purge_value != :listed_permissions

          purge_value = purge_value.to_s.downcase.to_sym unless purge_value.is_a?(Symbol)
          should_purge = purge_value == :true
          remove_permissions = purge_value == :listed_permissions
          if current_permissions.nil?
            current_local_permissions = []
          else
            current_local_permissions = current_permissions.select { |p| !p.is_inherited? }
          end

          if should_purge
            current_local_permissions == specified_permissions
          elsif remove_permissions
            return true if specified_permissions.nil?
            (specified_permissions & current_local_permissions) == []
          else
            return true if specified_permissions.nil?

            # intersect will return order by left item in intersect
            #  order is guaranteed checked when specified_permissions
            (current_local_permissions & specified_permissions) == specified_permissions
          end
        end

        def convert_to_dacl(permissions)
          dacl = Puppet::Util::Windows::AccessControlList.new
          return dacl if permissions.nil? || permissions.empty?

          permissions.each do |permission|
            sid = get_account_id(permission.identity)
            mask = get_account_mask(permission)
            flags = get_account_flags(permission)
            case permission.type
              when :allow
                dacl.allow(sid, mask, flags)
              when :deny
                dacl.deny(sid, mask, flags)
            end
          end

          dacl
        end

        def get_account_mask(permission, target_resource_type = :file)
          return 0 if permission.nil?
          return permission.mask.to_i if permission.mask
          return 0 if permission.rights.nil? || permission.rights.empty?

          mask = case target_resource_type
             when :file
               begin
                 if permission.rights.include?(:full)
                   return FILE_ALL_ACCESS
                 end

                 if permission.rights.include?(:modify)
                   return DELETE |
                       FILE_GENERIC_WRITE |
                       FILE_GENERIC_READ  |
                       FILE_GENERIC_EXECUTE
                 end

                 filemask = 0x0
                 if permission.rights.include?(:write)
                   filemask = filemask | FILE_GENERIC_WRITE
                 end

                 if permission.rights.include?(:read)
                   filemask = filemask | FILE_GENERIC_READ
                 end

                 if permission.rights.include?(:execute)
                   filemask = filemask | FILE_GENERIC_EXECUTE
                 end

                 filemask
               end
           end

          mask
        end
        module_function :get_account_mask

        def get_account_flags(permission)
          # http://msdn.microsoft.com/en-us/library/ms229747.aspx
          flags = 0x0

          case permission.child_types
            when :all
              flags = flags |
                      Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                      Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE
            when :objects
              flags = flags |
                      Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE
            when :containers
              flags = flags |
                      Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE
          end

          case permission.affects
            when :self_only
              flags =  0x0
            when :children_only
              flags = flags |
                      Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE
            when :self_and_direct_children_only
              flags = flags |
                      Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE
            when :direct_children_only
              flags = flags |
                      Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE |
                      Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE
          end

          if (permission.child_types == :none && flags != 0x0)
            flags = 0x0
          end

          flags
        end
        module_function :get_account_flags

        def sync_aces(current_dacl, should_aces, should_purge = false, remove_permissions = false)
          unless remove_permissions
            return should_aces if should_purge

            current_dacl.each do |ace|
              # todo v2 should we warn if we have an existing inherited ace that matches?
              next if ace.inherited?

              current_ace = Puppet::Type::Acl::Ace.new(convert_to_permissions_hash(ace), self)
              existing_aces = should_aces.select { |a| a.same?(current_ace) }
              next unless existing_aces.empty?

              # munge in existing unmanaged aces
              case current_ace.type
                when :deny
                  last_allow_index = should_aces.index{ |a| a.type == :allow}
                  should_aces.insert(last_allow_index,current_ace) if last_allow_index
                  should_aces << current_ace unless last_allow_index
                when :allow
                  should_aces << current_ace
              end
            end
          else
            kept_aces = []
            current_dacl.each do |ace|
              next if ace.inherited?

              current_ace = Puppet::Type::Acl::Ace.new(convert_to_permissions_hash(ace), self)
              existing_aces = should_aces.select { |a| a.same?(current_ace) }
              next unless existing_aces.empty?

              kept_aces << current_ace
            end

            should_aces = kept_aces
          end

          should_aces
        end

        def get_current_owner
          sd = get_security_descriptor

          sd.owner unless sd.nil?
        end

        def get_current_group
          sd = get_security_descriptor

          sd.group unless sd.nil?
        end

        def is_account_insync?(current, should)
          return false unless current

          should_empty = should.nil? || should.empty?
          return false if current.empty? != should_empty

          get_account_id(current) == get_account_id(should)
        end

        def get_account_id(name)
          # sometimes the name will come in with a SID
          # which will return nil when we call name_to_sid
          # if the user no longer exists
          if valid_sid?(name)
            name
          else
            name_to_sid(name)
          end
         end

        def get_account_name(current_value)
          name = sid_to_name(get_account_id(current_value))

          name ? name : current_value
        end
        alias_method :get_group_name, :get_account_name

        def is_inheriting_permissions?
          sd = get_security_descriptor

          return !sd.protect unless sd.nil?

          # default true
          true
        end

        def get_security_descriptor(refresh_sd = DO_NOT_REFRESH_SD)
          refresh_sd ||= false
          if @security_descriptor.nil? || refresh_sd
            sd = nil
            case @resource[:target_type]
              when :file
                begin
                  sd = Puppet::Util::Windows::Security.get_security_descriptor(@resource[:target])
                rescue => detail
                  raise Puppet::Error, "Failed to get security descriptor for path '#{@resource[:target]}': #{detail}", detail.backtrace
                end
            end

            @security_descriptor = sd
          end

          @security_descriptor
        end

        def set_security_descriptor(security_descriptor)
          case @resource[:target_type]
            when :file
              begin
                Puppet::Util::Windows::Security.set_security_descriptor(@resource[:target], security_descriptor)
              rescue => detail
                raise Puppet::Error, "Failed to set security descriptor for path '#{@resource[:target]}': #{detail}", detail.backtrace
              end
          end

          # flush out the cached sd
          get_security_descriptor(REFRESH_SD)
        end
      end
    end
  end
end

#todo v2 legacy - check to see if method exists for Puppet::Util::Windows::Security.get_security_descriptor, if not - we'll need to create it
