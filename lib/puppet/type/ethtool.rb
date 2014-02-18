Puppet::Type.newtype(:ethtool) do
  @doc = "Manage settings with ethtool."
  newparam(:name)
  newproperty(:tso) do
    desc "if TCP segment offload is enabled or disabled for this interface"
    newvalue(:enabled)
    newvalue(:disabled)
  end
  newproperty(:autonegotiate_tx) do
    desc "if autonegotiation is enabled or disabled for transmitting"
    newvalue(:enabled)
    newvalue(:disabled)
  end
  newproperty(:autonegotiate_rx) do
    desc "if autonegotiation is enabled or disabled for receiving"
    newvalue(:enabled)
    newvalue(:disabled)
  end
end

