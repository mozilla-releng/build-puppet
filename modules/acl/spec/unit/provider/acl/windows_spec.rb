#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/acl/windows'

describe Puppet::Type.type(:acl).provider(:windows), :if => Puppet.features.microsoft_windows? do

  let (:resource) { Puppet::Type.type(:acl).new(:provider => :windows, :name => "windows_acl") }
  let (:provider) { resource.provider }
  let (:catalog) { Puppet::Resource::Catalog.new }
  let (:base) { Puppet::Provider::Acl::Windows::Base }

  before :each do
    resource.provider = provider
  end

  it "should be an instance of Puppet::Type::Acl::ProviderWindows" do
    provider.must be_an_instance_of Puppet::Type::Acl::ProviderWindows
  end

  context "self.instances" do
    it "should return an empty array" do
      provider.class.instances.should == []
    end
  end

  context "autorequiring resources" do
    context "users" do
      def test_should_set_autorequired_user(user_name)
        user = Puppet::Type.type(:user).new(:name => user_name)
        catalog.add_resource resource
        catalog.add_resource user

        reqs = resource.autorequire
        reqs.count.must == 1
        reqs[0].source.must == user
        reqs[0].target.must == resource
      end

      def test_should_not_set_autorequired_user(user_name)
        user = Puppet::Type.type(:user).new(:name => user_name)
        catalog.add_resource resource
        catalog.add_resource user

        reqs = resource.autorequire
        reqs.must be_empty
      end

      it "should autorequire identities in permissions" do
        user_name = 'Administrator'
        resource[:permissions] = [{'identity'=>'bill','rights'=>['modify']},{'identity'=>user_name,'rights'=>['full']}]
        test_should_set_autorequired_user(user_name)
      end

      it "should not autorequire 'Administrators' if owner is set to the default Administrators SID" do
        # unfortunately we get the full account name 'BUILTIN\Administrators' which doesn't match Administrators
        test_should_not_set_autorequired_user('Administrators')
      end

      it "should autorequire BUILTIN\\Administrators if owner is set to the Administrators SID" do
        resource[:owner] = 'S-1-5-32-544'
        test_should_set_autorequired_user('BUILTIN\Administrators')
      end

      it "should autorequire fully qualified identities in permissions even if identities use SIDS" do
        resource[:owner] = 'Administrator'
        user_name = 'BUILTIN\Administrators'
        user_sid = 'S-1-5-32-544'

        resource[:permissions] = [{'identity'=>'bill','rights'=>['modify']},{'identity'=>user_sid,'rights'=>['full']}]
        test_should_set_autorequired_user(user_name)
      end
    end
  end

  context ":owner" do
    it "should be set to the default unspecified value by default" do
      resource[:owner].must be_nil
    end

    context ".insync?" do
      it "should return true for Administrators and S-1-5-32-544" do
        provider.owner_insync?("S-1-5-32-544","Administrators").must be_true
      end

      it "should return true for Administrators and Administrators" do
        provider.owner_insync?("Administrators","Administrators").must be_true
      end

      it "should return true for BUILTIN\\Administrators and Administrators" do
        provider.owner_insync?("BUILTIN\\Administrators","Administrators").must be_true
      end

      it "should return false for Administrators and Administrator (user)" do
        provider.owner_insync?("Administrators","Administrator").must be_false
      end
    end
  end

  context ":group" do
    it "should be set to the default unspecified value by default" do
      resource[:group].must be_nil
    end

    context ".insync?" do
      it "should return true for Administrators and S-1-5-32-544" do
        provider.group_insync?("S-1-5-32-544","Administrators").must be_true
      end

      it "should return true for Administrators and Administrators" do
        provider.group_insync?("Administrators","Administrators").must be_true
      end

      it "should return true for BUILTIN\\Administrators and Administrators" do
        provider.group_insync?("BUILTIN\\Administrators","Administrators").must be_true
      end

      it "should return false for Administrators and Administrator (user)" do
        provider.group_insync?("Administrators","Administrator").must be_false
      end
    end
  end

  context ":permissions" do
    let (:ace) { Puppet::Util::Windows::AccessControlEntry.new('S-1-5-32-544',0x31) }

    context ".get_ace_type" do
      it "should return allow if ace is nil" do
        ace.stubs(:type).returns(1) #ensure no false readings
        ace.expects(:nil?).returns(true)

        Puppet::Provider::Acl::Windows::Base.get_ace_type(ace).must == :allow
      end

      it "should return allow when ace.type is 0" do
        ace.expects(:type).returns(0)

        Puppet::Provider::Acl::Windows::Base.get_ace_type(ace).must == :allow
      end

      it "should return deny when ace.type is 1" do
        ace.expects(:type).returns(1)

        Puppet::Provider::Acl::Windows::Base.get_ace_type(ace).must == :deny
      end
    end

    context ".get_ace_child_types" do
      it "should return all if ace is nil" do
        ace.stubs(:container_inherit?).returns(false) #ensure no false readings
        ace.expects(:nil?).returns(true)

        Puppet::Provider::Acl::Windows::Base.get_ace_child_types(ace).must == :all
      end

      it "should return none when container_inherit and object_inherit are both false" do
        ace.expects(:container_inherit?).returns(false).at_least_once
        ace.expects(:object_inherit?).returns(false).at_least_once

        Puppet::Provider::Acl::Windows::Base.get_ace_child_types(ace).must == :none
      end

      it "should return objects when container_inherit is false and object_inherit is true" do
        ace.expects(:container_inherit?).returns(false).at_least_once
        ace.expects(:object_inherit?).returns(true).at_least_once

        Puppet::Provider::Acl::Windows::Base.get_ace_child_types(ace).must == :objects
      end

      it "should return containers when container_inherit is true and object_inherit is false" do
        ace.expects(:container_inherit?).returns(true).at_least_once
        ace.expects(:object_inherit?).returns(false).at_least_once

        Puppet::Provider::Acl::Windows::Base.get_ace_child_types(ace).must == :containers
      end

      it "should return all when container_inherit and object_inherit are both true" do
        ace.expects(:container_inherit?).returns(true).at_least_once
        ace.expects(:object_inherit?).returns(true).at_least_once

        Puppet::Provider::Acl::Windows::Base.get_ace_child_types(ace).must == :all
      end
    end

    context ".get_ace_propagation" do
      before :each do
        ace.expects(:container_inherit?).returns(true).times(0..1)
        ace.expects(:object_inherit?).returns(true).times(0..1)
        ace.expects(:inherit_only?).returns(false).times(0..2)
      end

      it "should return all if ace is nil" do
        ace.stubs(:inherit_only?).returns(true) #ensure no false readings
        ace.expects(:nil?).returns(true)

        Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :all
      end

      context "includes self" do
        it "should return all when when ace.inherit_only? is false, ace.object_inherit? is true and ace.container_inherit? is true" do
          Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :all
        end

        it "should return all when when ace.inherit_only? is false, ace.object_inherit? is false and ace.container_inherit? is true (only one container OR object inherit type is required)" do
          ace.expects(:object_inherit?).returns(false).times(0..1)
          Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :all
        end

        it "should return all when when ace.inherit_only? is false, ace.object_inherit? is true and ace.container_inherit? is true (only one container OR object inherit type is required)" do
          ace.expects(:container_inherit?).returns(false).times(0..1)
          Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :all
        end

        it "should return self_only when ace.inherit_only? is false, ace.object_inherit? is false and ace.container_inherit? is false" do
          ace.expects(:container_inherit?).returns(false).times(0..1)
          ace.expects(:object_inherit?).returns(false).times(0..1)
          Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :self_only
        end

        it "should return self_and_direct_children when ace.inherit_only? is false and no_propagation_flag is set" do
          ace.expects(:flags).returns(0x4) # http://msdn.microsoft.com/en-us/library/windows/desktop/ms692524(v=vs.85).aspx

          Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :self_and_direct_children_only
        end
      end

      context "inherit only (IO)" do
        before :each do
          ace.expects(:inherit_only?).returns(true).times(0..2)
        end

        it "should return children_only when ace.inherit_only? is true and no_propagation_flag is not set" do
          ace.expects(:flags).returns(0x10)

          Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :children_only
        end

        it "should return direct_children_only when ace.inherit_only? is true and no_propagation_flag is set" do
          ace.expects(:flags).returns(0x4) # http://msdn.microsoft.com/en-us/library/windows/desktop/ms692524(v=vs.85).aspx

          Puppet::Provider::Acl::Windows::Base.get_ace_propagation(ace).must == :direct_children_only
        end
      end
    end

    context ".get_ace_rights_from_mask" do
      it "should return [] if ace is nil?" do
        ace.expects(:nil?).returns(true)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == []
      end

      it "should have only full if ace.mask contains GENERIC_ALL" do
        ace.expects(:mask).returns(base::GENERIC_ALL).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:full]
      end

      it "should have only full if ace.mask contains FILE_ALL_ACCESS" do
        ace.expects(:mask).returns( base::FILE_ALL_ACCESS).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:full]
      end

      it "should contain read, write, execute if ace.mask contains GENERIC_WRITE, GENERIC_READ, and GENERIC_EXECUTE" do
        ace.expects(:mask).returns(base::GENERIC_WRITE |
                                   base::GENERIC_READ |
                                   base::GENERIC_EXECUTE ).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:write,:read,:execute]
      end

      it "should contain read, write, execute if ace.mask contains FILE_GENERIC_WRITE, FILE_GENERIC_READ, and FILE_GENERIC_EXECUTE" do
        ace.expects(:mask).returns(base::FILE_GENERIC_WRITE |
                                   base::FILE_GENERIC_READ |
                                   base::FILE_GENERIC_EXECUTE ).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:write,:read,:execute]
      end

      it "should contain write, execute if ace.mask contains FILE_GENERIC_WRITE and FILE_GENERIC_EXECUTE" do
        ace.expects(:mask).returns(base::FILE_GENERIC_WRITE |
                                   base::FILE_GENERIC_EXECUTE ).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:write,:execute]
      end

      it "should contain modify if ace.mask contains GENERIC_WRITE, GENERIC_READ, GENERIC_EXECUTE and contains DELETE" do
        ace.expects(:mask).returns(base::GENERIC_WRITE |
                                   base::GENERIC_READ |
                                   base::GENERIC_EXECUTE |
                                   base::DELETE ).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:modify]
      end

      it "should contain modify if ace.mask contains FILE_GENERIC_WRITE, FILE_GENERIC_READ, FILE_GENERIC_EXECUTE and contains DELETE" do
        ace.expects(:mask).returns(base::FILE_GENERIC_WRITE |
                                   base::FILE_GENERIC_READ |
                                   base::FILE_GENERIC_EXECUTE |
                                   base::DELETE ).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:modify]
      end

      it "should contain read, execute if ace.mask contains GENERIC_READ and GENERIC_EXECUTE" do
        ace.expects(:mask).returns(base::GENERIC_READ |
                                   base::GENERIC_EXECUTE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:read,:execute]
      end

      it "should contain read, execute if ace.mask contains FILE_GENERIC_READ and FILE_GENERIC_EXECUTE" do
        ace.expects(:mask).returns(base::FILE_GENERIC_READ |
                                   base::FILE_GENERIC_EXECUTE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:read,:execute]
      end

      it "should contain write if ace.mask contains GENERIC_WRITE" do
        ace.expects(:mask).returns(base::GENERIC_WRITE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:write]
      end

      it "should contain write if ace.mask contains FILE_GENERIC_WRITE" do
        ace.expects(:mask).returns(base::FILE_GENERIC_WRITE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:write]
      end

      it "should contain mask_specific if ace.mask only contains FILE_WRITE_DATA" do
        ace.expects(:mask).returns(base::FILE_WRITE_DATA).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:mask_specific]
      end

      it "should contain mask_specific if ace.mask only contains FILE_APPEND_DATA" do
        ace.expects(:mask).returns(base::FILE_APPEND_DATA).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:mask_specific]
      end

      it "should contain read if ace.mask contains GENERIC_READ" do
        ace.expects(:mask).returns(base::GENERIC_READ).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:read]
      end

      it "should contain read if ace.mask contains FILE_GENERIC_READ" do
        ace.expects(:mask).returns(base::FILE_GENERIC_READ).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:read]
      end

      it "should contain mask_specific if ace.mask contains FILE_GENERIC_READ | FILE_WRITE_ATTRIBUTES" do
        ace.expects(:mask).returns(base::FILE_GENERIC_READ |
                                   base::FILE_WRITE_ATTRIBUTES).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:mask_specific]
      end

      it "should contain mask_specific if ace.mask only contains FILE_READ_DATA" do
        ace.expects(:mask).returns(base::FILE_READ_DATA).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:mask_specific]
      end

      it "should contain execute if ace.mask contains GENERIC_EXECUTE" do
        ace.expects(:mask).returns(base::GENERIC_EXECUTE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:execute]
      end

      it "should contain execute if ace.mask contains FILE_GENERIC_EXECUTE" do
        ace.expects(:mask).returns(base::FILE_GENERIC_EXECUTE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:execute]
      end

      it "should contain mask_specific if ace.mask only contains FILE_EXECUTE" do
        ace.expects(:mask).returns(base::FILE_EXECUTE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:mask_specific]
      end

      it "should contain mask_specific if ace.mask contains permissions too specific" do
        ace.expects(:mask).returns(base::DELETE).times(0..10)

        Puppet::Provider::Acl::Windows::Base.get_ace_rights_from_mask(ace).must == [:mask_specific]
      end
    end

    context ".insync?" do
      context "when purge=>false (the default)" do
        it "should return true for Administrators and specifying Administrators with same permissions" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], [admins]).must be_true
        end

        it "should return true for Administrators and specifying Administrators even if one specifies sid and other non-required information" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']}, provider)
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'id'=>"S-1-5-32-544", 'mask'=>base::GENERIC_ALL, 'is_inherited'=>false})
          provider.are_permissions_insync?([admins], [admin2]).must be_true
        end

        it "should return true for Administrators and specifying Administrators when more current permissions exist than are specified" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          admin = Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']})
          provider.are_permissions_insync?([admin,admins], [admin]).must be_true
        end

        it "should return false for Administrators and specifying Administrators when more current permissions are specified than exist" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          admin = Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']})
          provider.are_permissions_insync?([admin], [admin,admins]).must be_false
        end

        it "should return false for Administrators and specifying Administrators if rights are different" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['modify']})
          provider.are_permissions_insync?([admins], [admin2]).must be_false
        end

        it "should return false for Administrators and specifying Administrators if types are different" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'type'=>'allow'})
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'type'=>'deny'})
          provider.are_permissions_insync?([admins], [admin2]).must be_false
        end

        it "should return false for Administrators and specifying Administrators if child_types are different" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'child_types'=>'all'})
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'child_types'=>'none'})
          provider.are_permissions_insync?([admins], [admin2]).must be_false
        end

        it "should return false for Administrators and specifying Administrators if affects are different" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'affects'=>'all'})
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'affects'=>'children_only'})
          provider.are_permissions_insync?([admins], [admin2]).must be_false
        end

        it "should return false for Administrators and specifying Administrators if current is inherited" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'is_inherited'=>'true'})
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], [admin2]).must be_false
        end

        it "should return true for Administrators and specifying S-1-5-32-544" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']}, provider)
          adminSID = Puppet::Type::Acl::Ace.new({'identity'=>'S-1-5-32-544', 'rights'=>['full']}, provider)
          provider.are_permissions_insync?([admins], [adminSID]).must be_true
        end

        it "should return false for nil and specifying Administrators" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?(nil, [admins]).must be_false
        end

        it "should return true for Administrators and specifying nil" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], nil).must be_true
        end

        it "should return true for Administrators and specifying []" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], []).must be_true
        end

        it "should return false for [] and specifying Administrators" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([], [admins]).must be_false
        end
      end

      context "when purge=>true" do
        it "should return true for Administrators and specifying Administrators with same permissions" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], [admins], :true).must be_true
        end

        it "should return true for Administrators and specifying Administrators even if one specifies sid and other non-required information" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']}, provider)
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'id'=>"S-1-5-32-544", 'mask'=>base::GENERIC_ALL, 'is_inherited'=>false}, provider)
          provider.are_permissions_insync?([admins], [admin2], :true).must be_true
        end

        it "should return false for Administrators and specifying Administrators when more current permissions exist than are specified" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          admin = Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']})
          provider.are_permissions_insync?([admin,admins], [admin], :true).must be_false
        end

        it "should return false for Administrators and specifying Administrators when more permissions are specified than exist" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          admin = Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']})
          provider.are_permissions_insync?([admin], [admin,admins], :true).must be_false
        end

        it "should return false for nil and specifying Administrators" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?(nil, [admins], :true).must be_false
        end

        it "should return false for Administrators and specifying nil" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], nil, :true).must be_false
        end

        it "should return false for Administrators and specifying []" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], [], :true).must be_false
        end

        it "should return false for [] and specifying Administrators" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([], [admins], :true).must be_false
        end
      end

      context "when purge=>listed_permissions" do
        it "should return false for Administrators and specifying Administrators with same permissions" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], [admins], :listed_permissions).must be_false
        end

        it "should return false for Administrators and specifying Administrators even if one specifies sid and other non-required information" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']}, provider)
          admin2 = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'id'=>"S-1-5-32-544", 'mask'=>base::GENERIC_ALL, 'is_inherited'=>false}, provider)
          provider.are_permissions_insync?([admins], [admin2], :listed_permissions).must be_false
        end

        it "should return false for Administrators and specifying Administrators when more current permissions exist than are specified" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          admin = Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']})
          provider.are_permissions_insync?([admin,admins], [admin], :listed_permissions).must be_false
        end

        it "should return false for Administrators and specifying Administrators when more permissions are specified than exist" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          admin = Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']})
          provider.are_permissions_insync?([admin], [admin,admins], :listed_permissions).must be_false
        end

        it "should return true for nil and specifying Administrators" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?(nil, [admins], :listed_permissions).must be_true
        end

        it "should return true for Administrators and specifying nil" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], nil, :listed_permissions).must be_true
        end

        it "should return true for Administrators and specifying []" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([admins], [], :listed_permissions).must be_true
        end

        it "should return true for [] and specifying Administrators" do
          admins = Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']})
          provider.are_permissions_insync?([], [admins], :listed_permissions).must be_true
        end
      end
    end

    context ".get_account_mask" do
      let (:ace) { Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']}) }

      it "should retun 0 if the ace is nil" do
        Puppet::Provider::Acl::Windows::Base.get_account_mask(nil).must be 0
      end

      it "should return ace.mask if the mask has a value" do
        ace.mask = 0x31
        Puppet::Provider::Acl::Windows::Base.get_account_mask(ace).must be 0x31
      end

      it "should return FILE_ALL_ACCESS if ace.rights includes 'full'" do
        ace.rights = ['full']
        Puppet::Provider::Acl::Windows::Base.get_account_mask(ace).must be base::FILE_ALL_ACCESS
      end

      it "should return mask including FILE_DELETE if ace.rights includes 'modify'" do
        ace.rights = ['modify']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::DELETE).must be base::DELETE
      end

      it "should return mask including FILE_GENERIC_WRITE if ace.rights includes 'modify'" do
        ace.rights = ['modify']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_WRITE).must be base::FILE_GENERIC_WRITE
      end

      it "should return mask including FILE_GENERIC_READ if ace.rights includes 'modify'" do
        ace.rights = ['modify']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_READ).must be base::FILE_GENERIC_READ
      end

      it "should return mask including FILE_GENERIC_EXECUTE if ace.rights includes 'modify'" do
        ace.rights = ['modify']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_EXECUTE).must be base::FILE_GENERIC_EXECUTE
      end

      it "should return mask that doesn't include FILE_ALL_ACCESS if ace.rights includes 'modify'" do
        ace.rights = ['modify']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_ALL_ACCESS).must_not be base::FILE_ALL_ACCESS
      end

      it "should return mask including FILE_GENERIC_WRITE if ace.rights includes 'write'" do
        ace.rights = ['write']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_WRITE).must be base::FILE_GENERIC_WRITE
      end

      it "should return mask that doesn't include FILE_GENERIC_READ if ace.rights only includes 'write'" do
        ace.rights = ['write']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_READ).must_not be base::FILE_GENERIC_READ
      end

      it "should return mask that doesn't include FILE_GENERIC_EXECUTE if ace.rights only includes 'write'" do
        ace.rights = ['write']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_EXECUTE).must_not be base::FILE_GENERIC_EXECUTE
      end

      it "should return mask including FILE_GENERIC_READ if ace.rights includes 'read'" do
        ace.rights = ['read']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_READ).must be base::FILE_GENERIC_READ
      end

      it "should return mask that doesn't include FILE_GENERIC_WRITE if ace.rights only includes 'read'" do
        ace.rights = ['read']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_WRITE).must_not be base::FILE_GENERIC_WRITE
      end

      it "should return mask that doesn't include FILE_GENERIC_EXECUTE if ace.rights only includes 'read'" do
        ace.rights = ['read']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_EXECUTE).must_not be base::FILE_GENERIC_EXECUTE
      end

      it "should return mask including FILE_GENERIC_EXECUTE if ace.rights only includes 'execute'" do
        ace.rights = ['execute']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_EXECUTE).must be base::FILE_GENERIC_EXECUTE
      end

      it "should return mask that doesn't include FILE_GENERIC_WRITE if ace.rights only includes 'execute'" do
        ace.rights = ['execute']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_WRITE).must_not be base::FILE_GENERIC_WRITE
      end

      it "should return mask that doesn't include FILE_GENERIC_READ if ace.rights only includes 'execute'" do
        ace.rights = ['execute']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_READ).must_not be base::FILE_GENERIC_READ
      end

      it "should return mask that doesn't include FILE_GENERIC_READ if ace.rights only includes 'execute'" do
        ace.rights = ['execute']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_READ).must_not be base::FILE_GENERIC_READ
      end

      it "should return mask that includes FILE_GENERIC_READ if ace.rights == ['read',execute']" do
        ace.rights = ['read','execute']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_READ).must be base::FILE_GENERIC_READ
      end

      it "should return mask that includes FILE_GENERIC_EXECUTE if ace.rights == ['read',execute']" do
        ace.rights = ['read','execute']
        mask = Puppet::Provider::Acl::Windows::Base.get_account_mask(ace)
        (mask & base::FILE_GENERIC_EXECUTE).must be base::FILE_GENERIC_EXECUTE
      end
    end

    context ".get_account_flags" do
      let (:ace) { Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['full']}) }

      it "should return (OI)(CI) for child_types => 'all', affects => 'all' (defaults)" do
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE)
      end

      it "should return 0x0 (no flags) when child_types => 'none'" do
        ace.child_types = "none"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        flags.must == 0x0
      end

      it "should return 0x0 (no flags) when affects => 'self_only'" do
        ace.affects = "self_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        flags.must == 0x0
      end

      it "should return (CI) for child_types => 'containers', affects => 'all'" do
        ace.child_types = "containers"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE)
      end

      it "should return (OI) for child_types => 'objects', affects => 'all'" do
        ace.child_types = "objects"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE)
      end

      it "should return (OI)(CI)(IO) for child_types => 'all', affects => 'children_only'" do
        ace.affects = "children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
      end

      it "should return (CI)(IO) for child_types => 'containers', affects => 'children_only'" do
        ace.child_types = "containers"
        ace.affects = "children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
      end

      it "should return (OI)(IO) for child_types => 'objects', affects => 'children_only'" do
        ace.child_types = "objects"
        ace.affects = "children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
      end

      it "should return (OI)(CI)(NP) for child_types => 'all', affects => 'self_and_direct_children_only'" do
        ace.affects = "self_and_direct_children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE)
      end

      it "should return (CI)(NP) for child_types => 'containers', affects => 'self_and_direct_children_only'" do
        ace.child_types = "containers"
        ace.affects = "self_and_direct_children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE)
      end

      it "should return (OI)(NP) for child_types => 'objects', affects => 'self_and_direct_children_only'" do
        ace.child_types = "objects"
        ace.affects = "self_and_direct_children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE)
      end

      it "should return (OI)(CI)(IO)(NP) for child_types => 'all', affects => 'direct_children_only'" do
        ace.affects = "direct_children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
      end

      it "should return (CI)(IO)(NP) for child_types => 'containers', affects => 'direct_children_only'" do
        ace.child_types = "containers"
        ace.affects = "direct_children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
      end

      it "should return (OI)(IO)(NP) for child_types => 'objects', affects => 'direct_children_only'" do
        ace.child_types = "objects"
        ace.affects = "direct_children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        (flags & (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE |
                  Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
        ).must be (Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE |
                   Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE)
      end

      it "should return 0x0 (no flags) when child_types => 'none', affects=> 'children_only' (effectively ignoring affects)" do
        ace.child_types = "none"
        ace.affects = "children_only"
        flags = Puppet::Provider::Acl::Windows::Base.get_account_flags(ace)
        flags.must == 0x0
      end

      it "should log a warning when child_types => 'none' and affects is not 'all' (default) or 'self_only'" do
        Puppet.expects(:warning).with() do |v|
          /If child_types => 'none', affects => value/.match(v)
        end
        ace.child_types = "none"
        ace.affects = "children_only"
      end
    end

    context ".sync_aces" do
      let (:current_dacl) { Puppet::Util::Windows::AccessControlList.new() }
      let (:should_aces) { [Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full']}),Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['modify']})] }
      let (:should_purge) { false }

      before :each do
        # explicit (CI)(OI)
        current_dacl.allow(provider.get_account_id('Users'), base::FILE_ALL_ACCESS, Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE | Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE)
        # explicit (IO) no propagate
        current_dacl.allow(provider.get_account_id('Users'), base::FILE_GENERIC_READ | base::FILE_GENERIC_EXECUTE, Puppet::Util::Windows::AccessControlEntry::NO_PROPAGATE_INHERIT_ACE | Puppet::Util::Windows::AccessControlEntry::INHERIT_ONLY_ACE )
        # add inherited
        current_dacl.allow(provider.get_account_id('Administrators'), base::FILE_ALL_ACCESS, Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE | Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE | Puppet::Util::Windows::AccessControlEntry::INHERITED_ACE )
      end

      it "should ignore the current dacl aces and only return the should aces when purge => true" do
        should_purge = true
        provider.sync_aces(current_dacl,should_aces,should_purge).must == should_aces
      end

      it "should not add inherited to returned aces" do
        current_dacl = Puppet::Util::Windows::AccessControlList.new()
        current_dacl.allow(provider.get_account_id('Administrators'), base::FILE_ALL_ACCESS, Puppet::Util::Windows::AccessControlEntry::OBJECT_INHERIT_ACE | Puppet::Util::Windows::AccessControlEntry::CONTAINER_INHERIT_ACE | Puppet::Util::Windows::AccessControlEntry::INHERITED_ACE )
        provider.sync_aces(current_dacl,should_aces,should_purge).must == should_aces
      end

      it "should add an unmanaged deny ace to the front of the array" do
        should_aces[0].type.must == :allow
        current_dacl.deny(provider.get_account_id('Administrator'), base::FILE_ALL_ACCESS, 0x0)
        aces = provider.sync_aces(current_dacl,should_aces,should_purge)

        sut_ace = aces[0]
        sut_ace.type.must == :deny
        sut_ace.identity.must == provider.get_account_name('Administrator')
      end

      it "should add unmanaged deny aces to the front of the array in proper order" do
        should_aces[0].type.must == :allow
        current_dacl.deny(provider.get_account_id('Administrator'), base::FILE_ALL_ACCESS, 0x0)
        current_dacl.deny(provider.get_account_id('Users'), base::FILE_ALL_ACCESS, 0x0)
        aces = provider.sync_aces(current_dacl,should_aces,should_purge)

        sut_ace = aces[0]
        sut_ace.type.must == :deny
        sut_ace.identity.must == provider.get_account_name('Administrator')
      end

      it "should add unmanaged deny aces after existing managed deny aces" do
        should_aces = [Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'type'=>'deny'}),Puppet::Type::Acl::Ace.new({'identity'=>'Administrator', 'rights'=>['modify']})]
        current_dacl.deny(provider.get_account_id('Administrator'), base::FILE_ALL_ACCESS, 0x0)
        current_dacl.deny(provider.get_account_id('Users'), base::FILE_ALL_ACCESS, 0x0)
        aces = provider.sync_aces(current_dacl,should_aces,should_purge)

        sut_ace = aces[2]
        sut_ace.type.must == :deny
        sut_ace.identity.must == provider.get_account_name('Users')
      end

      it "should add unmanaged deny aces after existing managed deny aces when there are no allowed aces" do
        should_aces = [Puppet::Type::Acl::Ace.new({'identity'=>'Administrators', 'rights'=>['full'], 'type'=>'deny'})]
        current_dacl = Puppet::Util::Windows::AccessControlList.new()
        current_dacl.deny(provider.get_account_id('Administrator'), base::FILE_ALL_ACCESS, 0x0)
        current_dacl.deny(provider.get_account_id('Users'), base::FILE_ALL_ACCESS, 0x0)
        aces = provider.sync_aces(current_dacl,should_aces,should_purge)

        sut_ace = aces[2]
        sut_ace.type.must == :deny
        sut_ace.identity.must == provider.get_account_name('Users')
      end

      it "should add unmanaged allow aces after existing managed aces" do
        aces = provider.sync_aces(current_dacl,should_aces,should_purge)

        aces.count.must == 4
        sut_ace = aces[2]
        sut_ace.identity.must == provider.get_account_name('Users')
      end
    end

    context ".convert_to_dacl" do
      it "should return properly" do
        resource[:permissions] = {'identity'=>'Administrator','rights'=>['full']}
        dacl = provider.convert_to_dacl(resource[:permissions])
        dacl.each do |ace|
          ace.sid.must == provider.get_account_id('Administrator')
          (ace.mask & base::FILE_ALL_ACCESS).must be base::FILE_ALL_ACCESS
        end
      end
    end
  end
end
