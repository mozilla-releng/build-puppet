Puppet::Type.type(:assert).provide(:ruby) do
  desc "The assert implementation."

  def exists?
    false
  end

  def create
    raise Puppet::Error, "Assert Failed: #{resource[:name]}" if not resource[:condition]
  end

  def destroy
    raise Puppet::Error, "Assert Failed: #{resource[:name]}" if not resource[:condition]
  end
end
