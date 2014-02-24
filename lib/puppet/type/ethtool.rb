Puppet::Type.newtype(:ethtool) do
  @doc = "Manage settings with ethtool."
  newparam(:name)
  {
    :tso => 'if TCP segment offload is enabled or disabled for this interface',
    :ufo => 'Specifies whether UDP fragmentation offload should be enabled or disabled',
    :gso => 'Specifies whether generic segmentation offload should be enabled',
    :gro => 'Specifies whether generic receive offload should be enabled',
    :sg => 'Specifies whether scatter-gather should be enabled',
    :checksum_rx => 'Specifies whether RX checksumming should be enabled',
    :checksum_tx => 'Specifies whether TX checksumming should be enabled',
    :autonegotiate_tx => 'if autonegotiation is enabled or disabled for transmitting',
    :autonegotiate_rx => 'if autonegotiation is enabled or disabled for receiving'
  }.each do |name, description|
    newproperty(name) do
      desc description
      newvalue(:enabled)
      newvalue(:disabled)
    end
  end
end

