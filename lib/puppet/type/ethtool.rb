module PuppetX
  module Type
    module EthTool
      module InSyncMixin
        def insync?(is)
          if is == 'unknown' and resource[:ignore_unknown] == true
            true
          else
            super(is)
          end
        end
      end
    end
  end
end
Puppet::Type.newtype(:ethtool) do
  @doc = "Manage settings with ethtool."
  newparam(:ignore_unknown) do
    defaultto(true)
  end
  newproperty(:speed) do
    desc "The speed of the interface: auto/10/100/1000/10000. Note that not all speeds are supported on every interface"
    newvalue(:auto)
    newvalue(:'10')
    newvalue(:'100')
    newvalue(:'1000')
    newvalue(:'10000')
  end
  newproperty(:duplex) do
    desc "The duplex setting for the interface: full half or auto"
    newvalue(:full)
    newvalue(:half)
    newvalue(:auto)
  end
  newparam(:name)
  {
    :tso => 'if TCP segment offload is enabled or disabled for this interface',
    :lro => 'Specifies whether large receive offload should be enabled or disabled',
    :ufo => 'Specifies whether UDP fragmentation offload should be enabled or disabled',
    :gso => 'Specifies whether generic segmentation offload should be enabled',
    :gro => 'Specifies whether generic receive offload should be enabled',
    :sg => 'Specifies whether scatter_gather should be enabled',
    :checksum_rx => 'Specifies whether RX checksumming should be enabled',
    :checksum_tx => 'Specifies whether TX checksumming should be enabled',
    :autonegotiate => 'if autonegotiation is enabled or disabled',
    :autonegotiate_tx => 'if autonegotiation is enabled or disabled for transmitting',
    :autonegotiate_rx => 'if autonegotiation is enabled or disabled for receiving',
    :adaptive_tx => '',
    :adaptive_rx => '',
    :txvlan => '',
    :rxvlan => '',
  }.each do |name, description|
    newproperty(name) do
      desc description if description != ''
      newvalue(:enabled)
      newvalue(:disabled)
      include PuppetX::Type::EthTool::InSyncMixin
    end
  end
  # FIXME - docs
  {:rx_usecs => '', :rx_frames => '', :rx_usecs_irq => '', :rx_frames_irq => '', :tx_usecs => '', :tx_frames => '', :tx_usecs_irq => '', :tx_frames_irq => '',
   :stats_block_usecs => '', :pkt_rate_low => '', :rx_usecs_low => '', :rx_frame_low => '', :tx_usecs_low => '', :tx_frame_low => '', :pkt_rate_high => '',
   :rx_usecs_high => '', :rx_frame_high => '', :tx_usecs_high => '', :tx_frame_high => '', :sample_interval=> ''}.each do |prop_name, prop_docs|
    newproperty(prop_name) do
      desc prop_docs if prop_docs != ''
      # FIXME Allow integers..
      include PuppetX::Type::EthTool::InSyncMixin
    end
  end 
end

