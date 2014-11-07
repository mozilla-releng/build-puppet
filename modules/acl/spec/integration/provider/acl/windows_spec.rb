#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/acl/windows'

if Puppet.features.microsoft_windows?
  class WindowsSecurityTester
    require 'puppet/util/windows/security'
    include Puppet::Util::Windows::Security
  end
end

describe Puppet::Type.type(:acl).provider(:windows), :if => Puppet.features.microsoft_windows? do
  let (:resource) { Puppet::Type.type(:acl).new(:provider => :windows, :name => "windows_acl") }
  let (:provider) { resource.provider }
  let (:top_level_path) do
    Dir.mktmpdir('acl_playground')
  end
  let (:path) { top_level_path }

  def set_path(sub_directory)
    path = File.join(top_level_path, sub_directory)
    Dir.mkdir(path) unless Dir.exists?(path)

    path
  end

  def set_perms(permissions, include_inherited = false)
    #resource[:permissions] = permissions
    provider.permissions = permissions
    resource.provider.flush

    if include_inherited
      provider.permissions
    else
      provider.permissions.select { |p| !p.is_inherited? }
    end
  end

  def get_permissions_for_path(path)
    sd = Puppet::Util::Windows::Security.get_security_descriptor(path)

    permissions = []
    sd.dacl.each do |ace|
      permissions << Puppet::Type::Acl::Ace.new(provider.convert_to_permissions_hash(ace), self)
    end

    permissions
  end

  before :each do
    resource.provider = provider
  end

  it "should throw an error for an invalid target" do
    resource[:target] = "c:/somwerhaear2132312323123123123123123_does_not_exist"

    expect {
      provider.owner.must_not be_nil
    }.to raise_error(Exception, /Failed to get security descriptor for path/)
  end

  context ":target" do
    before :each do
      resource[:target] = set_path('set_target')
    end

    it "should not allow permissions to be set on directory symlinks (PUP-2338)",
        :if => Puppet.features.manages_symlinks? && Puppet.features.microsoft_windows? do
      target_path = set_path('symlink_target')
      resource[:target] = File.expand_path("fake",resource[:target])
      Puppet::Util::Windows::File.symlink(target_path,resource[:target])

      expect {
        resource.validate
      }.to raise_error(Puppet::ResourceError, /Puppet cannot manage ACLs of symbolic links/)
    end

    it "should not allow permissions to be set on file symlinks (PUP-2338)",
        :if => Puppet.features.manages_symlinks? && Puppet.features.microsoft_windows? do
      target_path = set_path('symlink_target')
      file_path = File.join(target_path,"file.txt")
      FileUtils.touch(file_path)
      resource[:target] = File.expand_path("fakefile.txt",resource[:target])
      Puppet::Util::Windows::File.symlink(file_path,resource[:target])

      expect {
        resource.validate
      }.to raise_error(Puppet::ResourceError, /Puppet cannot manage ACLs of symbolic links/)
    end
  end

  context ":owner" do
    before :each do
      resource[:target] = set_path('owner_stuff')
    end

    it "should not be nil" do
      provider.owner.must_not be_nil
    end

    it "should grab current owner" do
      provider.owner.must == 'S-1-5-32-544'
    end

    context ".flush" do
      before :each do
        resource[:target] = set_path('set_owner')
      end

       it "should update owner to Administrator properly" do
         provider.owner.must == 'S-1-5-32-544'
         provider.owner = 'Administrator'

         resource.provider.flush

         provider.owner.must == provider.get_account_id('Administrator')
       end

       it "should not update owner to a user that does not exist" do
          expect {
            provider.owner = 'someuser1231235123112312312'
         }.to raise_error(Exception, /User does not exist/)
       end
    end
  end

  context ":group" do
    before :each do
      resource[:target] = set_path('group_stuff')
    end

    it "should not be nil" do
      provider.group.must_not be_nil
    end

    it "should grab current group" do
      # there really isn't a default group, it depends on the primary group of the original CREATOR GROUP of a resource.
      # http://msdn.microsoft.com/en-us/library/windows/desktop/ms676927(v=vs.85).aspx
      provider.group.must_not be_nil
    end

    context ".flush" do
      before :each do
        resource[:target] = set_path('set_group')
      end

       it "should update group to Administrator properly" do
         provider.group.must_not be_nil
         if provider.group == provider.get_account_id('Administrator')
           provider.group = 'Users'
           resource.provider.flush
         end
         provider.group.must_not == provider.get_account_id('Administrator')
         provider.group = 'Administrator'

         resource.provider.flush

         provider.group.must == provider.get_account_id('Administrator')
       end

       it "should not update group to a group that does not exist" do
          expect {
            provider.group = 'somegroup1231235123112312312'
         }.to raise_error(Exception, /Group does not exist/)
       end
    end
  end

  context ":inherit_parent_permissions" do
    before :each do
      resource[:target] = set_path('inheritance_stuff')
    end

    it "should not be nil" do
      provider.inherit_parent_permissions.must_not be_nil
    end

    it "should be true by default" do
      provider.inherit_parent_permissions.must be_true
    end

    context ".flush" do
      before :each do
        resource[:target] = set_path('set_inheritance')
      end

      it "should do nothing if inheritance is set to true (default)" do
        provider.inherit_parent_permissions.must be_true

        # puppet will not make this call if values are in sync
        #provider.inherit_parent_permissions = :true

        resource.provider.expects(:set_security_descriptor).never

        resource.provider.flush
      end

      it "should update inheritance to false when set to :false" do
        provider.inherit_parent_permissions.must be_true
        provider.inherit_parent_permissions = false

        resource.provider.flush

        provider.inherit_parent_permissions.must be_false
      end
    end
  end

  context ":permissions" do
    before :each do
      resource[:target] = set_path('permissions_stuff')
    end

    it "should not be nil" do
      provider.permissions.must_not be_nil
    end

    it "should contain at least one ace" do
      provider.permissions.count.must_not == 0
    end

    it "should contain aces that are access allowed" do
       at_least_one = false
       provider.permissions.each do |ace|
         if ace.type == :allow
           at_least_one = true
           break
         end
       end

       at_least_one.must be_true
    end

    it "should contain aces that allow inheritance" do
      at_least_one = false
      provider.permissions.each do |ace|
        case ace.child_types
          when :all, :objects, :containers
            at_least_one = true
            break
        end
      end

      at_least_one.must be_true
    end

    it "should contain aces that are inherited" do
      at_least_one = false
      provider.permissions.each do |ace|
        if ace.is_inherited?
          at_least_one = true
          break
        end
      end

      at_least_one.must be_true
    end

    it "should contain aces that propagate inheritance" do
      at_least_one = false
      provider.permissions.each do |ace|
        case ace.affects
          when :all, :children_only, :self_and_direct_children_only, :direct_children_only
            at_least_one = true
            break
        end
      end

      at_least_one.must be_true
    end

    context "when setting permissions" do
      before :each do
        resource[:target] = set_path('set_perms')
      end

      it "should not allow permissions to be set to a user that does not exist" do
        permissions = [Puppet::Type::Acl::Ace.new({'identity' => 'someuser1231235123112312312','rights' => ['full']})]

        expect {
          provider.permissions = permissions
        }.to raise_error(Exception, /User or users do not exist/)
      end

      it "should handle minimally specified permissions" do
        permissions = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider)]
        set_perms(permissions).must == permissions
      end

      it "should handle fully specified permissions" do
        permissions = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full'], 'type'=>'allow','child_types'=>'all','affects'=>'all'}, provider)]
        set_perms(permissions).must == permissions
      end

      it "should handle multiple users" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['modify']}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['write','read','execute']}, provider)
        ]
        set_perms(permissions).must == permissions
      end

      it "should handle setting folder protected" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider)
        ]
        provider.inherit_parent_permissions = :false

        set_perms(permissions).must == permissions

        perms_not_empty = false
        all_perms = get_permissions_for_path(resource[:target])
        all_perms.each do |perm|
          perms_not_empty = true
          perm.is_inherited?.must == false
        end

        perms_not_empty.must == true
      end

      it "should handle file permissions" do
        file_path = File.join(resource[:target],"file.txt")
        FileUtils.touch(file_path)
        resource[:target] = file_path
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider)
        ]
        resource[:purge] = true
        provider.inherit_parent_permissions = :false

        set_perms(permissions).must == permissions
      end

      it "should handle setting ace inheritance" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full'], 'child_types' => 'containers'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['full'], 'child_types' => 'objects'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['full'], 'child_types' => 'none'}, provider)
        ]
        resource[:purge] = :true
        provider.inherit_parent_permissions = :false

        set_perms(permissions).must == permissions
      end

      it "should handle extraneous rights" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full','modify']}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['modify','read']}, provider)
        ]
        resource[:purge] = :true
        provider.inherit_parent_permissions = :false

        actual_perms = set_perms(permissions)

        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['modify']}, provider)
        ]

        actual_perms.must == permissions
      end

      it "should handle deny" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['full'], 'type' => 'deny'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']}, provider)
        ]
        resource[:purge] = :true
        provider.inherit_parent_permissions = :false

        actual = set_perms(permissions)

        actual.must == permissions
      end

      it "should handle deny when affects => 'self_only'" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['full'], 'type' => 'deny', 'affects'=>'self_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']}, provider)
        ]
        resource[:purge] = :true
        provider.inherit_parent_permissions = :false

        set_perms(permissions).must == permissions
      end

      it "should handle the same user with differing permissions appropriately" do
        permissions = [
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['modify'], 'child_types' => 'none' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['modify'], 'child_types' => 'containers' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['modify'], 'child_types' => 'objects' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['full'], 'affects' => 'self_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['read','execute'], 'affects' => 'direct_children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['read','execute'], 'child_types' =>'containers', 'affects' => 'direct_children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['read','execute'], 'child_types' =>'objects', 'affects' => 'direct_children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['full'], 'affects' => 'children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['full'], 'child_types' =>'containers', 'affects' => 'children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['full'], 'child_types' =>'objects', 'affects' => 'children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['read'], 'affects' => 'self_and_direct_children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['read'], 'child_types' =>'containers', 'affects' => 'self_and_direct_children_only' }, provider),
            Puppet::Type::Acl::Ace.new({ 'identity' => 'SYSTEM', 'rights' => ['read'], 'child_types' =>'objects', 'affects' => 'self_and_direct_children_only' }, provider)
        ]
        resource[:purge] = :true
        provider.inherit_parent_permissions = :false

        set_perms(permissions).must == permissions
      end

      it "should handle setting propagation appropriately" do
        # tried to split this one up into multiple assertions but rspec mocks me
        path = set_path('set_perms_propagation')
        resource[:target] = path
        child_path = File.join(path, 'child_folder')
        Dir.mkdir(child_path) unless Dir.exists?(child_path)
        child_file = File.join(path, 'child_file.txt')
        File.new(child_file, 'w').close
        grandchild_file = File.join(child_path, 'grandchild_file.txt')
        File.new(grandchild_file, 'w').close
        grandchild_path = File.join(child_path, 'grandchild_folder')
        Dir.mkdir(grandchild_path) unless Dir.exists?(grandchild_path)

        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full'], 'affects' => 'all'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['write','read'], 'child_types'=>'objects', 'affects' => 'all'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['read'], 'child_types'=>'containers', 'affects' => 'all'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['modify'], 'affects' => 'self_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['full'], 'affects' => 'direct_children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['modify'], 'child_types' => 'objects', 'affects' => 'direct_children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['read'], 'child_types' => 'containers', 'affects' => 'direct_children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read'], 'affects' => 'children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read','execute'],'child_types' => 'objects', 'affects' => 'children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['modify'],'child_types' => 'containers', 'affects' => 'children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['read'], 'affects' => 'self_and_direct_children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['execute'], 'child_types' =>'objects', 'affects' => 'self_and_direct_children_only'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['write','read'], 'child_types' =>'containers', 'affects' => 'self_and_direct_children_only'}, provider)
        ]
        resource[:purge] = :true
        provider.inherit_parent_permissions = :false

        set_perms(permissions).must == permissions

        #child object
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full'], 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['write','read'], 'child_types'=>'objects', 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['full'], 'affects' => 'direct_children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['modify'], 'child_types' => 'objects', 'affects' => 'direct_children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read'], 'affects' => 'children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read','execute'],'child_types' => 'objects', 'affects' => 'children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['read'], 'affects' => 'self_and_direct_children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['execute'], 'child_types' =>'objects', 'affects' => 'self_and_direct_children_only', 'is_inherited' => 'true'}, provider)
        ]
        get_permissions_for_path(child_file)  == permissions

        #grandchild object
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full'], 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['write','read'], 'child_types'=>'objects', 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read'], 'affects' => 'children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read','execute'],'child_types' => 'objects', 'affects' => 'children_only', 'is_inherited' => 'true'}, provider)
        ]
        get_permissions_for_path(grandchild_file)  == permissions

        #child container
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full'], 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['read'], 'child_types'=>'containers', 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['full'], 'affects' => 'direct_children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['read'], 'child_types' => 'containers', 'affects' => 'direct_children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read'], 'affects' => 'children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['modify'],'child_types' => 'containers', 'affects' => 'children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['read'], 'affects' => 'self_and_direct_children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['write','read'], 'child_types' =>'containers', 'affects' => 'self_and_direct_children_only', 'is_inherited' => 'true'}, provider)
        ]
        get_permissions_for_path(child_path)  == permissions

        #grandchild container
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full'], 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['read'], 'child_types'=>'containers', 'affects' => 'all', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['read'], 'affects' => 'children_only', 'is_inherited' => 'true'}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['modify'],'child_types' => 'containers', 'affects' => 'children_only', 'is_inherited' => 'true'}, provider)
        ]
        get_permissions_for_path(grandchild_path)  == permissions
      end
    end
  end

  context ":purge" do
    before :each do
      resource[:target] = set_path('purge_stuff')
    end

    context "purge => true" do
      it "should remove unspecified explicit permissions" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['full']}, provider)
        ]
        resource[:purge] = :true

        set_perms(permissions).must == permissions

        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider)
        ]

        set_perms(permissions).must == permissions
      end

      it "with inherit_parent_permissions => false, should remove all but specified permissions" do
        permissions = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider),
            Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['full']}, provider)
        ]
        resource[:purge] = :true
        provider.inherit_parent_permissions = :false

        set_perms(permissions).must == permissions
        # all permissions including inherited should also be the same
        get_permissions_for_path(resource[:target]).must == permissions
      end

      context "when purge => true with a pre-existing manifest and inherit parent permissions is then set false (PUP-2036)" do
        let (:permissions_hash) { [
            {'identity' => 'Administrators','rights' => ['full']},
            {'identity' => 'SYSTEM','rights' => ['full']},
            {'identity' => 'Administrator','rights' => ['modify']}
        ] }

        let (:permissions) { [
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']}),
            Puppet::Type::Acl::Ace.new({'identity' => 'SYSTEM','rights' => ['full']}),
            Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['modify']})
        ] }

        before :each do
          resource[:target] = set_path('perms_purge_true_inherit_false_second_sync')
          resource[:purge] = true
          permissions.each do |perm|
            perm.id = provider.get_account_id(perm.identity)
            perm.identity = provider.get_account_name(perm.identity)
          end
          resource[:permissions] = permissions_hash

          set_perms(permissions).must == permissions
        end

        it "should remove the permissions successfully" do
          provider.inherit_parent_permissions = false
          resource.provider.flush

          provider.permissions.must == permissions
        end
      end
    end

    context "purge => listed_permissions" do
      let (:permissions) { [
          Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Administrator','rights' => ['modify']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Authenticated Users','rights' => ['write','read','execute']})
      ] }

      before :each do
        resource[:target] = set_path('perms_remove')
        permissions.each do |perm|
          perm.id = provider.get_account_id(perm.identity)
        end

        set_perms(permissions).must == permissions

      end

      it "should remove specified permissions" do
        resource[:purge] = :listed_permissions
        removing_perms = [
            Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}, provider)
        ]

        set_perms(removing_perms).must == (permissions - removing_perms)
      end

      context "when removing non-existing users" do
        begin
          require 'puppet/util/windows/adsi'
        rescue LoadError
          require 'puppet/util/adsi'
        end

        let (:adsi) { Puppet::Util::Windows.constants.include?(:ADSI) ? Puppet::Util::Windows::ADSI : Puppet::Util::ADSI }

        it "should allow it to work with SIDs" do
          user_name = "jimmy123456_randomyo"

          user = adsi::User.create(user_name) unless adsi::User.exists?(user_name)
          user = adsi::User.new(user_name) if adsi::User.exists?(user_name)
          user.commit
          sid = user.sid.to_s

          permissions = [
              Puppet::Type::Acl::Ace.new({'identity' => user_name,'rights' => ['modify']}, provider)
          ]
          set_perms(permissions).must == permissions

          adsi::User.delete(user_name)

          resource[:purge] = :listed_permissions
          removing_perms = [
              Puppet::Type::Acl::Ace.new({'identity' => sid,'rights' => ['modify']}, provider)
          ]

          permissions = get_permissions_for_path(resource[:target]).select { |p| !p.is_inherited? }
          set_perms(removing_perms).must == (permissions - removing_perms)
        end

      end
    end
  end

  context ".set_security_descriptor" do
    it "should handle nil security descriptor appropriately" do
      expect {
        provider.set_security_descriptor(nil)
      }.to raise_error(Exception, /Failed to set security descriptor for path/)
    end
  end
end
