#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet/type/acl'

describe "Ace" do
  context ".hash" do
    it "should be equal for two like aces" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}).hash

      expect(left).to eq right
    end

    it "should be equal for two like aces even with extra information" do
      sid = 'S-32-12-0'
      provider = mock()
      provider.expects(:get_account_id).returns(sid)
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'id'=> sid,'mask'=>'2023422'}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']},provider).hash

      expect(left).to eq right
    end

    it "should be equal for two like aces when one has sid" do
      sid = 'S-1-1-0'
      provider = mock()
      provider.expects(:get_account_id).returns(sid)
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone', 'id'=> sid,'rights' => ['full']}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']},provider).hash

      expect(left).to eq right
    end

    it "should be equal for two like aces when both have same sid but identities are different" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'id'=>'S-1-1-0', 'rights' => ['full']}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'BUILT IN\Administrators', 'id'=>'S-1-1-0','rights' => ['full']}).hash

      expect(left).to eq right
    end

    it "should be equal for two like aces when identities evaluate to the same because provider" do
      provider = mock()
      provider.expects(:get_account_name).returns('same').twice

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'BUILT IN\Administrators', 'rights' => ['full']}, provider).hash

      expect(left).to eq right
    end

    it "should not be equal for two like aces when identities do not evaluate to the same because provider" do
      provider = mock()
      provider.stubs(:get_account_name).returns('one','two')

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider).hash

      expect(left).to_not eq right
    end

    it "should be equal for two aces when SIDs evaluate to the same because provider" do
      provider = mock()
      provider.expects(:get_account_id).returns('S-1-1-0').twice

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'NOTAdministrators', 'rights' => ['full']}, provider).hash

      expect(left).to eq right
    end

    it "should not be equal for two like aces when SIDs evaluate different because provider" do
      provider = mock()
      provider.stubs(:get_account_id).returns('S-1-1-0','S-1-1-5')

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider).hash

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by identities" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Users', 'rights' => ['full']}).hash

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by rights" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['modify']}).hash

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by type" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'type'=>'allow'}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'type'=>'deny'}).hash

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by child_types" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'child_types'=>'all'}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'child_types'=>'objects'}).hash

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by affects" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'affects'=>'all'}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'affects'=>'children_only'}).hash

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by is_inherited" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'is_inherited'=>'false'}).hash
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'is_inherited'=>'true'}).hash

      expect(left).to_not eq right
    end
  end

  context ".==" do
    it "should be equal for two like aces" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})

      expect(left).to eq right
    end

    it "should be equal for two like aces even with extra information" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'id'=> 'S-32-12-0','mask'=>'2023422'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})

      expect(left).to eq right
    end

    it "should be equal for two like aces when one has sid" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone', 'id'=>'S-1-1-0','rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})

      expect(left).to eq right
    end

    it "should be equal for two like aces when both have same sid but identities are different" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'id'=>'S-1-1-0', 'rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'BUILT IN\Administrators', 'id'=>'S-1-1-0','rights' => ['full']})

      expect(left).to eq right
    end

    it "should be equal for two like aces when identities evaluate to the same because provider" do
      provider = mock()
      provider.expects(:get_account_name).returns('same').twice

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'BUILT IN\Administrators', 'rights' => ['full']}, provider)

      expect(left).to eq right
    end

    it "should not be equal for two like aces when identities do not evaluate to the same because provider" do
      provider = mock()
      provider.stubs(:get_account_name).returns('one','two')

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})

      expect(left).to_not eq right
    end

    it "should be equal for two aces when SIDs evaluate to the same because provider" do
      provider = mock()
      provider.expects(:get_account_id).returns('S-1-1-0').twice

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'NOTAdministrators', 'rights' => ['full']}, provider)

      expect(left).to eq right
    end

    it "should not be equal for two like aces when SIDs evaluate different because provider" do
      provider = mock()
      provider.stubs(:get_account_id).returns('S-1-1-0','S-1-1-5')

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by identities" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Users', 'rights' => ['full']})

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by rights" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['modify']})

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by type" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'type'=>'allow'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'type'=>'deny'})

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by child_types" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'child_types'=>'all'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'child_types'=>'objects'})

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by affects" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'affects'=>'all'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'affects'=>'children_only'})

      expect(left).to_not eq right
    end

    it "should not be equal if aces are different by is_inherited" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'is_inherited'=>'false'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'is_inherited'=>'true'})

      expect(left).to_not eq right
    end
  end

  context ".same?" do
    it "should be true for two like aces" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})

      expect(left.same? right).to be_true
    end

    it "should be true for two like aces even with extra information" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'id'=> 'S-32-12-0','mask'=>'2023422'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})

      expect(left.same? right).to be_true
    end

    it "should be true for two like aces when one has sid" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone', 'id'=>'S-1-1-0','rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})

      expect(left.same? right).to be_true
    end

    it "should be true for two like aces when both have same sid but identities are different" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'id'=>'S-1-1-0', 'rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'BUILT IN\Administrators', 'id'=>'S-1-1-0','rights' => ['full']})

      expect(left.same? right).to be_true
    end

    it "should be true for two like aces when identities evaluate to the same because provider" do
      provider = mock()
      provider.expects(:get_account_name).returns('same').twice

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'BUILT IN\Administrators', 'rights' => ['full']}, provider)

      expect(left.same? right).to be_true
    end

    it "should be false for two like aces when identities do not evaluate to the same because provider" do
      provider = mock()
      provider.stubs(:get_account_name).returns('one','two')

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})

      expect(left.same? right).to be_false
    end

    it "should be true for two aces when SIDs evaluate to the same because provider" do
      provider = mock()
      provider.expects(:get_account_id).returns('S-1-1-0').twice

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'NOTAdministrators', 'rights' => ['full']}, provider)

      expect(left.same? right).to be_true
    end

    it "should be false for two like aces when SIDs evaluate different because provider" do
      provider = mock()
      provider.stubs(:get_account_id).returns('S-1-1-0','S-1-1-5')

      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']}, provider)

      expect(left.same? right).to be_false
    end

    it "should be true if aces are different by rights" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['modify']})

      expect(left.same? right).to be_true
    end

    it "should be false if aces are different by identities" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Users', 'rights' => ['full']})

      expect(left.same? right).to be_false
    end

    it "should be false if aces are different by type" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'type'=>'allow'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'type'=>'deny'})

      expect(left.same? right).to be_false
    end

    it "should be false if aces are different by child_types" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'child_types'=>'all'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'child_types'=>'objects'})

      expect(left.same? right).to be_false
    end

    it "should be false if aces are different by affects" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'affects'=>'all'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'affects'=>'children_only'})

      expect(left.same? right).to be_false
    end

    it "should be false if aces are different by is_inherited" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'is_inherited'=>'false'})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Administrators', 'rights' => ['full'],'is_inherited'=>'true'})

      expect(left.same? right).to be_false
    end
  end

  context "with arrays" do
    it "should be equal for two like ace arrays" do
      left = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]
      right = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]

      expect(left).to eq right
    end

    it "should not be equal for two unlike ace arrays" do
      left = [Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']})]
      right = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]

      expect(left).to_not eq right
    end

    it "the union of two like ace arrays should return the same as one of the arrays" do
      left = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]
      right = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]

      expect(left | right).to eq left
    end

    it "the intersect of two like ace arrays should return the same as one of the arrays" do
      left = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]
      right = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]

      expect(left & right).to eq left
    end

    it "the intersect of two ace arrays with similar elements should return an array with common elements" do
      left = [
          Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']})
      ]
      right = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]

      expect(left & right).to eq right
    end

    it "the intersect of two ace arrays with similar elements should return an array with common elements no matter where the common elements occur" do
      left = [
          Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']})
      ]
      right = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]

      expect(left & right).to eq right
    end

    it "the intersect of two like ace arrays out of order should return the same as the element on the left of the '&'" do
      left = [
          Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']})
      ]
      right = [
          Puppet::Type::Acl::Ace.new({'identity' => 'Users','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Administrators','rights' => ['full']}),
          Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})

      ]

      expect(left & right).to eq left
      expect(right & left).to eq right
    end

    it "the difference of two like ace arrays should return an empty array" do
      left = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]
      right = [Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})]

      expect(left - right).to eq []
    end
  end

  context ".eql?" do
    it "should be true for two like aces" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})

      expect(left.eql? right).to be_true
    end

    it "should be an alias of .==" do
      type = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})
      expect(type.method(:==)).to eq type.method(:eql?)
    end
  end

  context ".equal?" do
    it "should not be equal for two like aces" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})
      right = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})

      expect(left.equal? right).to be_false
    end

    it "should be equal for two aces that are the same object" do
      left = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})
      right = left

      expect(left.equal? right).to be_true
    end

    it "should not be an alias of .==" do
      type = Puppet::Type::Acl::Ace.new({'identity' => 'Everyone','rights' => ['full']})
      expect(type.method(:==)).to_not eq type.method(:equal?)
    end
  end
end
