Puppet::Type.newtype(:ethtool) do
  @doc = "Manage settings with ethtool."
  newparam(:name)
  newproperty(:tso) do
    desc "if TCP segment offload is enabled or disabled for this interface"
    newvalue(:enabled)
    newvalue(:disabled)
  end
end

