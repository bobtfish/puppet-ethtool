Puppet::Type.type(:ethtool).provide(:linux) do
  confine :kernel => :linux
  commands :ethtool => 'ethtool'

  def exists?
    begin
      ethtool(resource[:name])
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def tso
    ethtool('-k', resource[:name]).split(/\n/).find { |line| line =~ /tcp[ -]segmentation[ -]offload/ }.split(/: /)[1] == 'on' ? 'enabled' : 'disabled'
  end
  def tso=(value)
    setting = case value
    when :enabled
      'on'
    when :disabled
      'off'
    else
      raise("tso setting should be enabled or disabled, not #{value}")
    end
    ethtool('-K', resource[:name], 'tso', setting)
  end

  def autonegotiate_tx
    ethtool('-a', resource[:name]).split(/\n/).find { |line| line =~ /TX/ }.split(/ +/)[1] == 'on' ? 'enabled' : 'disabled'
  end
  def autonegotiate_tx=(value)
    setting = case value
    when :enabled
      'on'
    when :disabled
      'off'
    else
      raise("autonegotiate_tx setting should be enabled or disabled, not #{value}")
    end
    ethtool('-A', resource[:name], 'tx', setting)
  end

  def autonegotiate_rx
    ethtool('-a', resource[:name]).split(/\n/).find { |line| line =~ /RX/ }.split(/ +/)[1] == 'on' ? 'enabled' : 'disabled'
  end
  def autonegotiate_rx=(value)
    setting = case value
    when :enabled
      'on'
    when :disabled
      'off'
    else
      raise("autonegotiate_rx setting should be enabled or disabled, not #{value}")
    end
    ethtool('-A', resource[:name], 'rx', setting)
  end
end

