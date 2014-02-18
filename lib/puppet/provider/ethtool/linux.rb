Puppet::Type.type(:ethtool).provide(:linux) do
  confine :kernel => :linux
  commands :ethtool => 'ethtool'

  def exists?
    begin
      ethtool(resource[:name])
      STDERR.puts("EXISTS")
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def tso
    current = ethtool('-k', resource[:name]).split(/\n/).find { |line| line =~ /tcp-segmentation-offload/ }.split(/ /)[1] == 'on' ? 'enabled' : 'disabled'
    STDERR.puts "Current #{current}"
    current
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
end

