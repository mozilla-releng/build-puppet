module Puppet::Util::MonkeyPatches
end


if Puppet::Util::Platform.windows?

  require 'win32/security'
  # http://stackoverflow.com/a/2954632/18475
  # only monkey patch older versions that have the flaw with certain accounts
  # and stripping what appears to be whitespace
  # we only want to path pre-FFI versions, and we have the luxury of knowing that
  # we will be skipping from 0.1.4 straight to the latest FFI-ed, fixed version
  # see https://github.com/djberg96/win32-security/issues/3
  if Gem.loaded_specs["win32-security"].version < Gem::Version.new('0.2.0')
    # monkey patch that bad boy
    Win32::Security::SID.class_eval do
      # Error class typically raised if any of the SID methods fail
      class Error < StandardError; end

      def initialize(account=nil, host=Socket.gethostname)
        if account.nil?
          htoken = [0].pack('L')
          bool   = OpenThreadToken(GetCurrentThread(), TOKEN_QUERY, 1, htoken)
          errno  = GetLastError()

          if !bool
            if errno == ERROR_NO_TOKEN
              unless OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, htoken)
                raise get_last_error
              end
            else
              raise get_last_error(errno)
            end
          end

          htoken = htoken.unpack('V').first
          cbti = [0].pack('L')
          token_info = 0.chr * 36

          bool = GetTokenInformation(
              htoken,
              TokenOwner,
              token_info,
              token_info.size,
              cbti
          )

          unless bool
            raise Error, get_last_error
          end
        end

        bool   = false
        sid    = 0.chr * 80
        sid_cb = [sid.size].pack('L')

        domain_buf = 0.chr * 80
        domain_cch = [domain_buf.size].pack('L')

        sid_name_use = 0.chr * 4

        if account
          ordinal_val = account[0]
          ordinal_val = ordinal_val.ord if RUBY_VERSION.to_f >= 1.9
        else
          ordinal_val = nil
        end

        if ordinal_val.nil?
          bool = LookupAccountSid(
              nil,
              token_info.unpack('L')[0],
              sid,
              sid_cb,
              domain_buf,
              domain_cch,
              sid_name_use
          )
        elsif ordinal_val < 10 # Assume it's a binary SID.
          bool = LookupAccountSid(
              host,
              [account].pack('p*').unpack('L')[0],
              sid,
              sid_cb,
              domain_buf,
              domain_cch,
              sid_name_use
          )
        else
          bool = LookupAccountName(
              host,
              account,
              sid,
              sid_cb,
              domain_buf,
              domain_cch,
              sid_name_use
          )
        end

        unless bool
          raise Error, get_last_error
        end

        # The arguments are flipped depending on which path we took
        if ordinal_val.nil?
          buf = 0.chr * 260
          ptr = token_info.unpack('L')[0]
          memcpy(buf, ptr, token_info.size)
          @sid = buf.strip
          @account = sid.strip
        elsif ordinal_val < 10
          @sid     = account
          @account = sid.strip
        else
          # all that necessary just for these two lines
          length = GetLengthSid(sid)
          @sid = sid[0,length]
          @account = account
        end

        @host   = host
        @domain = domain_buf.strip

        @account_type = get_account_type(sid_name_use.unpack('L')[0])
      end
    end
  end

  require 'puppet/util/windows/security'
  # PUP-2100 - https://tickets.puppetlabs.com/browse/PUP-2100
  # backporting that fix to earlier versions of Puppet.
  # PUP-1987 - https://tickets.puppetlabs.com/browse/PUP-1987
  if Puppet.version < '3.6.0'

    module Puppet::Util::Windows::Security

      def add_access_denied_ace(acl, mask, sid, inherit = nil)
        inherit ||= NO_INHERITANCE

        string_to_sid_ptr(sid) do |sid_ptr|
          raise Puppet::Util::Windows::Error.new("Invalid SID") unless IsValidSid(sid_ptr)

          unless AddAccessDeniedAceEx(acl, ACL_REVISION, inherit, mask, sid_ptr)
            raise Puppet::Util::Windows::Error.new("Failed to add access control entry")
          end
        end
      end

      #need to bring this in as well so it can all add_access_denied_ace properly
      # setting DACL requires both READ_CONTROL and WRITE_DACL access rights,
      # and their respective privileges, SE_BACKUP_NAME and SE_RESTORE_NAME.
      def set_security_descriptor(path, sd)
        # REMIND: FFI
        acl = 0.chr * 1024 # This can be increased later as neede
        unless InitializeAcl(acl, acl.size, ACL_REVISION)
          raise Puppet::Util::Windows::Error.new("Failed to initialize ACL")
        end

        raise Puppet::Util::Windows::Error.new("Invalid DACL") unless IsValidAcl(acl)

        with_privilege(SE_BACKUP_NAME) do
          with_privilege(SE_RESTORE_NAME) do
            open_file(path, READ_CONTROL | WRITE_DAC | WRITE_OWNER) do |handle|
              string_to_sid_ptr(sd.owner) do |ownersid|
                string_to_sid_ptr(sd.group) do |groupsid|
                  sd.dacl.each do |ace|
                    case ace.type
                      when ACCESS_ALLOWED_ACE_TYPE
                        #puts "ace: allow, sid #{sid_to_name(ace.sid)}, mask 0x#{ace.mask.to_s(16)}"
                        add_access_allowed_ace(acl, ace.mask, ace.sid, ace.flags)
                      when ACCESS_DENIED_ACE_TYPE
                        #puts "ace: deny, sid #{sid_to_name(ace.sid)}, mask 0x#{ace.mask.to_s(16)}"
                        add_access_denied_ace(acl, ace.mask, ace.sid, ace.flags)
                      else
                        raise "We should never get here"
                        # this should have been a warning in an earlier commit
                    end
                  end

                  # protected means the object does not inherit aces from its parent
                  flags = OWNER_SECURITY_INFORMATION | GROUP_SECURITY_INFORMATION | DACL_SECURITY_INFORMATION
                  flags |= sd.protect ? PROTECTED_DACL_SECURITY_INFORMATION : UNPROTECTED_DACL_SECURITY_INFORMATION

                  rv = SetSecurityInfo(handle,
                                       SE_FILE_OBJECT,
                                       flags,
                                       ownersid,
                                       groupsid,
                                       acl,
                                       nil)
                  raise Puppet::Util::Windows::Error.new("Failed to set security information") unless rv == ERROR_SUCCESS
                end
              end
            end
          end
        end
      end
    end
  end
end
