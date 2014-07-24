Puppet::Type.newtype('assert') do                                                                                                                                        
  desc "This type will simply assert that a condition is true. Useful for skipping classes that don't apply cleanly. Anything that requires a failing instance of this type will fail."
  
  ensurable do
    desc "If ensure is present, then this assert will take effect"

    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.delete
    end
    
    defaultto :present
  end
  
  newparam(:name, :namevar => true) do
    desc "The name of the assert."
  end
  
  newparam(:condition) do
    desc "The condition. Pass true to succeed and false to fail."
  end
end
