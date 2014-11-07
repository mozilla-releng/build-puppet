#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/type/acl'

describe Puppet::Type.type(:acl) do
  let(:resource) { Puppet::Type.type(:acl).new(:name => "acl") }
  let(:provider) { Puppet::Provider.new(resource) }
  let(:catalog) { Puppet::Resource::Catalog.new }

  before :each do
    resource.provider = provider
  end

  it "should be an instance of Puppet::Type::Acl" do
    resource.must be_an_instance_of Puppet::Type::Acl
  end

  context "parameter :name" do
    it "should be the name var" do
      resource.parameters[:name].isnamevar?.should be_true
    end

    it "should not allow nil" do
      expect {
        resource[:name] = nil
      }.to raise_error(Puppet::Error, /Got nil value for name/)
    end

    it "should not allow empty" do
      expect {
        resource[:name] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty name must/)
    end

    it "should accept any string value" do
      resource[:name] = 'value'
      resource[:name] = "c:/thisstring-location/value/somefile.txt"
      resource[:name] = "c:\\thisstring-location\\value\\somefile.txt"
    end
  end

  context "parameter :target" do
    it "should default to name" do
      resource[:target].must == resource[:name]
    end

    it "should not allow nil" do
      expect {
        resource[:target] = nil
      }.to raise_error(Puppet::Error, /Got nil value for target/)
    end

    it "should not allow empty" do
      expect {
        resource[:target] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty target must/)
    end

    it "should accept any string value" do
      resource[:target] = 'value'
      resource[:target] = "c:/thisstring-location/value/somefile.txt"
      resource[:target] = "c:\\thisstring-location\\value\\somefile.txt"
    end

    it "should not override :name" do
      resource[:target] = 'somevalue'
      resource[:target].should_not == resource[:name]
    end
  end

  context "parameter :target_type" do
    it "should default to :file" do
      resource[:target_type].must == :file
    end

    it "should accept :file" do
      resource[:target_type] = :file
    end

    it "should reject any other value" do
      expect {
        resource[:target_type] = :whenever
      }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are file/)
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

      it "should not autorequire owner when set to unspecified" do
        test_should_not_set_autorequired_user('Administrators')
      end

      it "should autorequire owner when set to Administrators" do
        resource[:owner] = 'Administrators'
        test_should_set_autorequired_user(resource[:owner])
      end

      it "should not autorequire group when set to unspecified" do
        test_should_not_set_autorequired_user('Administrators')
      end

      it "should autorequire group when set to Administrators" do
        resource[:group] = 'Administrators'
        test_should_set_autorequired_user(resource[:group])
      end

      it "should not autorequire Administrators if owner is set to the default Administrators SID" do
        # we have no way at the type level of knowing that Administrators == S-1-5-32-544 - this would require a call to the provider
        # unfortunately even in the provider we get the full account name 'BUILTIN\Administrators' which doesn't match Administrators
        test_should_not_set_autorequired_user('Administrators')
      end

      it "should not autorequire BUILTIN\\Administrators if owner is set to the default Administrators SID" do
        # we have no way at the type level of knowing that BUILTIN\Administrators == S-1-5-32-544 - this would require a call to the provider
        # check the provider for a similar test that notes the require works
        test_should_not_set_autorequired_user('BUILTIN\Administrators')
      end

      it "should autorequire identities in permissions" do
        user_name = 'bob'
        resource[:permissions] = [{'identity'=>'bill','rights'=>['modify']},{'identity'=>user_name,'rights'=>['full']}]
        test_should_set_autorequired_user(user_name)
      end

      it "should autorequire identities in permissions once even when included more than once" do
        user_name = 'bob'
        resource[:permissions] = [{'identity'=>user_name,'rights'=>['modify'],'affects'=>'children_only'},{'identity'=>user_name,'rights'=>['full']}]
        test_should_set_autorequired_user(user_name)
      end

      it "should not autorequire users that are not part of the owner or permission identities" do
        resource[:permissions] = [{'identity'=>'bob','rights'=>['modify']}]
        test_should_not_set_autorequired_user('bill')
      end

      it "should not autorequire identities/owner if their is not a match to a user in the catalog" do
        resource[:owner] = 'Administrators'
        resource[:permissions] = [{'identity'=>'bob','rights'=>['modify']}]
        catalog.add_resource resource

        reqs = resource.autorequire
        reqs.must be_empty
      end
    end

    context "groups" do
      def test_should_set_autorequired_group(group_name)
        group = Puppet::Type.type(:group).new(:name => group_name)
        catalog.add_resource resource
        catalog.add_resource group

        reqs = resource.autorequire
        reqs.count.must == 1
        reqs[0].source.must == group
        reqs[0].target.must == resource
      end

      def test_should_not_set_autorequired_group(group_name)
        group = Puppet::Type.type(:group).new(:name => group_name)
        catalog.add_resource resource
        catalog.add_resource group

        reqs = resource.autorequire
        reqs.must be_empty
      end

      it "should not autorequire owner when set to unspecified" do
        test_should_not_set_autorequired_group('Administrators')
      end

      it "should autorequire owner when set to Administrators" do
        resource[:owner] = 'Administrators'
        test_should_set_autorequired_group(resource[:owner])
      end

      it "should not autorequire group when set to unspecified" do
        test_should_not_set_autorequired_group('Administrators')
      end

      it "should autorequire group when set to Administrators" do
        resource[:group] = 'Administrators'
        test_should_set_autorequired_group(resource[:group])
      end

      it "should not autorequire Administrators if owner is set to the default Administrators SID" do
        # we have no way at the type level of knowing that Administrators == S-1-5-32-544 - this would require a call to the provider
        # unfortunately even in the provider we get the full account name 'BUILTIN\Administrators' which doesn't match Administrators
        test_should_not_set_autorequired_group('Administrators')
      end

      it "should not autorequire BUILTIN\\Administrators if owner is set to the default Administrators SID" do
        # we have no way at the type level of knowing that BUILTIN\Administrators == S-1-5-32-544 - this would require a call to the provider
        # check the provider for a similar test that notes the require works
        test_should_not_set_autorequired_group('BUILTIN\Administrators')
      end

      it "should autorequire identities in permissions" do
        user_name = 'bob'
        resource[:permissions] = [{'identity'=>'bill','rights'=>['modify']},{'identity'=>user_name,'rights'=>['full']}]
        test_should_set_autorequired_group(user_name)
      end

      it "should autorequire identities in permissions once even when included more than once" do
        user_name = 'bob'
        resource[:permissions] = [{'identity'=>user_name,'rights'=>['modify'],'affects'=>'children_only'},{'identity'=>user_name,'rights'=>['full']}]
        test_should_set_autorequired_group(user_name)
      end

      it "should not autorequire groups that are not part of the owner or permission identities" do
        resource[:permissions] = [{'identity'=>'bob','rights'=>['modify']}]
        test_should_not_set_autorequired_group('bill')
      end

      it "should not autorequire identities/owner if their is not a match to a group in the catalog" do
        resource[:owner] = 'Administrators'
        resource[:permissions] = [{'identity'=>'bob','rights'=>['modify']}]
        catalog.add_resource resource

        reqs = resource.autorequire
        reqs.must be_empty
      end
    end

    # :as_platform => :windows - doesn't exist outside of puppet?
    context "when :target_type => :file", :if => Puppet.features.microsoft_windows? do
      def test_should_set_autorequired_file(resource_path,file_path)
        resource[:target] = resource_path
        dir = Puppet::Type.type(:file).new(:path => file_path)
        catalog.add_resource resource
        catalog.add_resource dir
        reqs = resource.autorequire

        reqs.count.must == 1
        reqs[0].source.must == dir
        reqs[0].target.must == resource
      end

      it "should autorequire an existing file resource when acl.target matches file.path exactly" do
        test_should_set_autorequired_file('c:/temp',"c:/temp")
      end

      it "should autorequire an existing file resource when acl.target uses back slashes and file.path uses forward slashes" do
        test_should_set_autorequired_file('c:\temp',"c:/temp")
      end

      it "should autorequire an existing file resource when acl.target uses forward slashes and file.path uses back slashes" do
        test_should_set_autorequired_file('c:/temp','c:\temp')
      end

      it "should autorequire an existing file resource when acl.target is lowercase but file.path has different casing", :if => Puppet.version.to_f >= 3.5 do
        test_should_set_autorequired_file('c:/temp',"c:/Temp")
      end

      it "should autorequire an existing file resource when acl.target has uppercase but file.path has different casing", :if => Puppet.version.to_f >= 3.5 do
        test_should_set_autorequired_file('c:/Temp',"c:/tEmp")
      end

      it "should autorequire an existing file resource when acl.target has different casing than file.path", :if => Puppet.version.to_f >= 3.5 do
        test_should_set_autorequired_file('c:/Temp',"c:/temp")
      end

      it "should autorequire an existing file resource when acl.target volume is uppercase C and file.path is uppercase C" do
        test_should_set_autorequired_file('C:/temp',"C:/temp")
      end

      it "should autorequire an existing file resource when acl.target volume is uppercase C and file.path is lowercase c" do
        test_should_set_autorequired_file('C:/temp',"c:/temp")
      end

      it "should autorequire an existing file resource when acl.target volume is lowercase C and file.path is uppercase C" do
        test_should_set_autorequired_file('c:/temp',"C:/temp")
      end

      it "should not autorequire an existing file resource when it is different than acl.target" do
        resource[:target] = 'c:/temp'
        dir = Puppet::Type.type(:file).new(:path => "c:/temp/something")
        catalog.add_resource resource
        catalog.add_resource dir
        reqs = resource.autorequire

        reqs.must be_empty
      end
    end
  end

  context "parameter :purge" do
    it "should default to nil" do
      resource[:purge].must == :false
    end

    it "should accept true" do
      resource[:purge] = true
    end

    it "should accept false" do
      resource[:purge] = false
    end

    it "should accept 'true'" do
      resource[:purge] = 'true'
    end

    it "should accept 'false'" do
      resource[:purge] = 'false'
    end

    it "should accept :true" do
      resource[:purge] = :true
    end

    it "should accept :false" do
      resource[:purge] = :false
    end

    it "should accept :listed_permissions" do
      resource[:purge] = :listed_permissions
    end

    it "should reject non-boolean values" do
      expect {
        resource[:purge] = :whenever
      }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are true/)
    end
  end

  context "property :owner" do
    it "should default to use the default unspecified group" do
      resource[:owner].must be_nil
    end

    it "should accept bob" do
      resource[:owner] = 'bob'
    end

    it "should accept Domain\\Bob" do
      resource[:owner] = 'Domain\Bob'
    end

    it "should accept SIDs like S-1-5-32-544" do
      resource[:owner] = 'S-1-5-32-544'
    end

    it "should not allow nil" do
      expect {
        resource[:owner] = nil
      }.to raise_error(Puppet::Error, /Got nil value for owner/)
    end

    it "should not allow empty" do
      expect {
        resource[:owner] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty owner must/)
    end

    it "should accept any string value" do
      resource[:owner] = 'value'
      resource[:owner] = "c:/thisstring-location/value/somefile.txt"
      resource[:owner] = "c:\\thisstring-location\\value\\somefile.txt"
    end
  end

  context "property :group" do
    it "should default to use the default unspecified group" do
      resource[:group].must be_nil
    end

    it "should accept bob" do
      resource[:group] = 'bob'
    end

    it "should accept Domain\\Bob" do
      resource[:group] = 'Domain\Bob'
    end

    it "should accept SIDs like S-1-5-32-544" do
      resource[:group] = 'S-1-5-32-544'
    end

    it "should not allow nil" do
      expect {
        resource[:group] = nil
      }.to raise_error(Puppet::Error, /Got nil value for group/)
    end

    it "should not allow empty" do
      expect {
        resource[:group] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty group must/)
    end

    it "should accept any string value" do
      resource[:group] = 'value'
      resource[:group] = "c:/thisstring-location/value/somefile.txt"
      resource[:group] = "c:\\thisstring-location\\value\\somefile.txt"
    end
  end

  context "property :inherit_parent_permissions" do
    it "should default to true" do
      resource[:inherit_parent_permissions].must == :true
    end

    context "when the provider has implemented :can_inherit_parent_permissions" do
      before :each do
        resource.provider.class.expects(:satisfies?).with(:can_inherit_parent_permissions).returns(true)
      end

      it "should accept true" do
        resource[:inherit_parent_permissions] = true
      end

      it "should accept false" do
        resource[:inherit_parent_permissions] = false
      end

      it "should reject non-boolean values" do
        expect {
          resource[:inherit_parent_permissions] = :whenever
        }.to raise_error(Puppet::ResourceError, /Invalid value :whenever. Valid values are true/)
      end
    end
  end

  context "property :permissions" do
    it "should not accept empty array" do
      expect {
        Puppet::Type.type(:acl).new(:name => "acl",:permissions =>[])
      }.to raise_error(Puppet::ResourceError, /Value for permissions should be an array with at least one element specified/)
    end

    it "should not allow empty string" do
      expect {
        resource[:permissions] = ''
      }.to raise_error(Puppet::ResourceError, /A non-empty permissions must be/)
    end

    it "should not allow nil" do
      expect {
        resource[:permissions] = nil
      }.to raise_error(Puppet::Error, /Got nil value for permissions/)
    end

    it "should be of type Array" do
      resource[:permissions] = [{'identity'=>'bob','rights'=>['full']}]
      resource[:permissions].must be_an_instance_of Array
    end

    it "should be an array that has elements of type Puppet::Type::Acl::Ace" do
      resource[:permissions] = {'identity' =>'bob','rights'=>['full']}
      resource[:permissions].each do |permission|
        permission.must be_an_instance_of Puppet::Type::Acl::Ace
      end
    end

    it "should not allow inherited aces in manifests" do
      expect {
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'is_inherited'=>'true'}
      }.to raise_error(Puppet::ResourceError, /Puppet can not manage inherited ACEs/)
    end

    it "should not log a warning when an ace contains child_types => 'none' and affects => 'self_only'" do
      Puppet.expects(:warning).never
      resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'child_types'=>'none','affects'=>'self_only'}
    end

    it "should not log a warning when an ace contains child_types => 'none' and affects is set to 'all' (default)" do
      Puppet.expects(:warning).never
      resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'child_types'=>'none'}
    end

    it "should not log a warning when an ace contains affects => 'self_only' and child_types is set to 'all' (default)" do
      Puppet.expects(:warning).never
      resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'affects'=>'self_only'}
    end

    it "should log a warning when an ace contains child_types => 'none' and affects is not 'all' (default) or 'self_only'" do
      Puppet.expects(:warning).with() do |v|
        /If child_types => 'none', affects => value/.match(v)
      end
      resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'child_types'=>'none','affects'=>'children_only'}
    end

    it "should log a warning when an ace contains affects => 'self_only' and child_types is not 'all' (default) or 'none'" do
      Puppet.expects(:warning).with() do |v|
        /If affects => 'self_only', child_types => value/.match(v)
      end
      resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'child_types'=>'containers','affects'=>'self_only'}
    end

    context "formatting" do
      it "when called from puppet resource should format like a hash and ASCIIbetical order properties when displaying" do
        # properties are out of order here
        resource[:permissions] = [{'rights'=>['full'], 'child_types' => 'containers', 'identity'=> 'bob'},{'rights'=>['full'], 'identity'=> 'tim'}]

        # ordered asciibetically
        expected = "[{'child_types' => 'containers', 'identity' => 'bob', 'rights' => ['full']}, {'identity' => 'tim', 'rights' => ['full']}]"

        Puppet::Parameter.format_value_for_display(resource[:permissions]).should == expected
      end

      it "when called from puppet should format much better when displaying" do
        # properties are out of order here
        resource[:permissions] = [{'rights'=>['read','write'], 'type'=> 'deny', 'child_types' => 'containers', 'identity'=> 'bob'},{'rights'=>['full'], 'identity'=> 'tim'}]

        # and spaced / ordered properly here
        expected = "[
 { identity => 'bob', rights => [\"write\", \"read\"], type => 'deny', child_types => 'containers' },\s
 { identity => 'tim', rights => [\"full\"] }
]"

        resource.parameters[:permissions].class.format_value_for_display(resource[:permissions]).should == expected
      end
    end

    context ":identity" do
      it "should accept bob" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full']}
      end

      it "should accept Domain\\Bob" do
        resource[:permissions] = {'identity' =>'Domain\Bob','rights'=>['full']}
      end

      it "should accept SIDs like S-1-5-32-544" do
        resource[:permissions] = {'identity' =>'S-1-5-32-544','rights'=>['full']}
      end

      it "should use the SID when the system returns a non-existing user" do
        resource[:permissions] = {'identity'=>'', 'id' =>'S-1-5-32-544','rights'=>['full']}
      end

      it "should reject empty" do
        expect {
          resource[:permissions] = {'rights'=>['full']}
        }.to raise_error(Puppet::ResourceError, /A non-empty identity must/)
      end

      it "should reject nil" do
        expect {
          resource[:permissions] = {'identity'=>nil,'rights'=>['full']}
        }.to raise_error(Puppet::ResourceError, /A non-empty identity must/)
      end
    end

    context ":rights" do
      it "should accept ['full']" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['full']}
      end

      it "should accept ['modify']" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['modify']}
      end

      it "should accept ['write']" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['write']}
      end

      it "should accept ['read']" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['read']}
      end

      it "should accept ['execute']" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['execute']}
      end

      it "should accept ['mask_specific']" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['mask_specific'],'mask'=>'123123'}
      end

      it "should accept a combination of valid values" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['read','execute']}
      end

      it "should reorder [:execute,:read] to [:read,:execute]" do
        resource[:permissions] = {'identity'=>'bob','rights'=>[:execute,:read]}
        resource[:permissions][0].rights.should == [:read,:execute]
      end

      it "should set ['read','read'] to [:read]" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['read','read']}
        resource[:permissions][0].rights.should == [:read]
      end

      it "should not allow improperly cased rights like ['READ']" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['READ']}
        }.to raise_error(Puppet::ResourceError, /Invalid value "READ". Valid values are/)
      end

      it "should log a warning when rights does not contain 'full' by itself" do
        Puppet.expects(:warning).with() do |v|
          /In each ace, when specifying rights, if you include 'full'/.match(v)
        end
        resource[:permissions] = {'identity'=>'bob','rights'=>['full','read']}
      end

      it "should remove all but 'full' when rights does not contain 'full' by itself" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['full','read']}
        resource[:permissions][0].rights.should == [:full]
      end

      it "should log a warning when rights does not contain 'modify' by itself" do
        Puppet.expects(:warning).with() do |v|
          /In each ace, when specifying rights, if you include 'modify'/.match(v)
        end
        resource[:permissions] = {'identity'=>'bob','rights'=>['modify','read']}
      end

      it "should remove all but 'modify' when rights does not contain 'modify' by itself" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['modify','read']}
        resource[:permissions][0].rights.should == [:modify]
      end

      it "should not allow 'mask_specific' to exist with other rights" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['mask_specific','read']}
        }.to raise_error(Puppet::ResourceError, /In each ace, when specifying rights, if you include 'mask_specific'/)
      end

      it "should not allow 'mask_specific' without mask" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['mask_specific']}
        }.to raise_error(Puppet::ResourceError, /If you specify rights => \['mask_specific'\], you must also include mask/)
      end

      it "should set ['read',:read] to [:read]" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['read',:read]}
        resource[:permissions][0].rights.should == [:read]
      end

      it "should reject any other value" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['what']}
        }.to raise_error(Puppet::ResourceError, /Invalid value "what". Valid values are/)
      end

      it "should reject a value even if with valid values" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['modify','what']}
        }.to raise_error(Puppet::ResourceError, /Invalid value "what". Valid values are/)
      end

      it "should reject non-array value" do
        expect {
          resource[:permissions] = {'identity'=>'bob','rights'=>'read'}
        }.to raise_error(Puppet::ResourceError, /Value for rights should be an array. Perhaps try \['read'\]\?/)
      end

      it "should reject empty" do
        expect {
          resource[:permissions] = {'identity'=>'bob'}
        }.to raise_error(Puppet::ResourceError, /A non-empty rights must/)
      end

      it "should reject nil" do
        expect {
          resource[:permissions] = {'identity'=>'bob','rights'=>nil}
        }.to raise_error(Puppet::ResourceError, /A non-empty rights must/)
      end

      it "should reject emtpy array" do
        expect {
          resource[:permissions] = {'identity'=>'bob','rights'=>[]}
        }.to raise_error(Puppet::ResourceError, /Value for rights should have least one element in the array/)
      end
    end

    context ":type" do
      it "should default to allow" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full']}
        resource[:permissions][0].type.should == :allow
      end

      it "should accept allow" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'type'=>'allow'}
      end

      it "should accept deny" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'type'=>'deny'}
      end

      it "should reject any other value" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'type'=>'what'}
        }.to raise_error(Puppet::ResourceError, /Invalid value "what". Valid values are/)
      end

      it "should reject empty" do
        expect {
          resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'type'=>''}
        }.to raise_error(Puppet::ResourceError, /Invalid value "". Valid values are/)
      end

      it "should set default value on nil" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'type'=>nil}
        resource[:permissions][0].type.should == :allow
      end
    end

    context ":child_types" do
      it "should default to 'all'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full']}
        resource[:permissions][0].child_types.should == :all
      end

      it "should accept 'all'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'child_types'=>'all'}
      end

      it "should accept 'none'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'child_types'=>'none'}
      end

      it "when set to 'none' should update affects to 'self_only'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'child_types'=>'none'}
        resource[:permissions][0].affects.should == :self_only
      end

      it "should accept 'objects'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'child_types'=>'objects'}
      end

      it "should accept 'containers'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'child_types'=>'containers'}
      end

      it "should reject any other value" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'child_types'=>'what'}
        }.to raise_error(Puppet::ResourceError, /Invalid value "what". Valid values are/)
      end

      it "should reject empty" do
        expect {
          resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'child_types'=>''}
        }.to raise_error(Puppet::ResourceError, /Invalid value "". Valid values are/)
      end

      it "should set default value on nil" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'child_types'=>nil}
        resource[:permissions][0].child_types.should == :all
      end
    end

    context ":affects" do
      it "should default to 'all'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full']}
        resource[:permissions][0].affects.should == :all
      end

      it "should accept 'all'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'affects'=>'all'}
      end

      it "should accept 'self_only'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'affects'=>'self_only'}
      end

     it "when set to 'self_only' should update child_types to 'none'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'affects'=>'self_only'}
        resource[:permissions][0].child_types.should == :none
      end

      it "should accept 'children_only'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'affects'=>'children_only'}
      end

      it "should accept 'self_and_direct_children_only'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'affects'=>'self_and_direct_children_only'}
      end

      it "should accept 'direct_children_only'" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'affects'=>'direct_children_only'}
      end

      it "should reject any other value" do
        expect {
          resource[:permissions] = {'identity' =>'bob','rights'=>['full'],'affects'=>'what'}
        }.to raise_error(Puppet::ResourceError, /Invalid value "what". Valid values are/)
      end

      it "should reject empty" do
        expect {
          resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'affects'=>''}
        }.to raise_error(Puppet::ResourceError, /Invalid value "". Valid values are/)
      end

      it "should set default value on nil" do
        resource[:permissions] = {'identity'=>'bob','rights'=>['full'],'affects'=>nil}
        resource[:permissions][0].affects.should == :all
      end
    end

    context "when working with a single permission" do

      before :each do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full']}
      end

      it "should convert the values appropriately" do
        resource[:permissions] = {'identity' =>'bob','rights'=>['full']}

        resource[:permissions][0].identity.should == 'bob'
        resource[:permissions][0].rights.should == [:full]
      end

      it "should set defaults" do
        resource[:permissions][0].type.should == :allow
        resource[:permissions][0].child_types.should == :all
        resource[:permissions][0].affects.should == :all
      end
    end

    context "when working with multiple permissions" do
      before :each do
        resource[:permissions] = [{'identity'=> 'bob','rights'=>['full']},{'identity'=> 'tim','rights'=>['full']}]
      end

      it "should contain the number of items set" do
        resource[:permissions].count.must == 2
      end

      it "should be in the exact order set" do
        resource[:permissions][0].identity.must == 'bob'
        resource[:permissions][1].identity.must == 'tim'
      end
    end

  end
end
