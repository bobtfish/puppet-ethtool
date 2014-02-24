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

  # Hairy metaprogramming rather than a load of boringly similar methods :)
  { /: / => {
      :arg => 'k',
      :properties => {
        'tso' => { :re => /tcp[ -]segmentation[ -]offload/, :arg => 'tso' },
        'lro' => { :re => /large[ -]receive[ -]offload/ },
        'ufo' => { :re => /udp[ -]fragmentation[ -]offload/ },
        'gso' => { :re => /generic[ -]segmentation[ -]offload/ },
        'gro' => { :re => /generic[ -]receive[ -]offload/ },
        'sg' => { :re => /scatter[ -]gather/ },
        'checksum_rx' => { :re => /rx[ -]checksumming/, :arg => 'rx' },
        'checksum_tx' => { :re => /tx[ -]checksumming/, :arg => 'tx' },
      }
    },
    / +/ => {
      :arg => 'a',
      :properties => {
        'autonegotiate' => { :re => /Autonegotiate/, :arg => 'autoneg' },
        'autonegotiate_tx' => { :re => /TX/, :arg => 'tx' },
        'autonegotiate_rx' => { :re => /RX/, :arg => 'rx' }
      }
    }
  }.each do |split_re, data|
    get_arg = "-#{data[:arg]}"
    set_arg = "-#{data[:arg].upcase}"
    data[:properties].each do |name, data|
      define_method name do
        answer = ethtool(get_arg, resource[:name]).split(/\n/).find { |line| line =~ data[:re] }
        if answer
          answer.split(split_re)[1] == 'on' ? 'enabled' : 'disabled'
        else
          'unknown'
        end
      end
      define_method("#{name}=") do |value|
        argument = data[:arg] || name
        ethtool_setonoff(name, set_arg, argument, value)
      end
    end
  end

  # Adaptive RX: off  TX: off
  def adaptive_rx
    answer = ethtool('-c', resource[:name]).split(/\n/).find { |line| /Adaptive RX:/ }
    if answer
      answer.split(/ +/)[3]
    else
      'unknown'
    end
  end
  def adaptive_rx=(value)
    ethtool_setonoff('adaptive_rx', '-C', 'adaptive-rx', value)
  end
  def adaptive_tx
    answer = ethtool('-c', resource[:name]).split(/\n/).find { |line| /Adaptive.+TX:/ }
    if answer
      answer.gsub(/.*TX:\s*/, '')
    else
      'unknown'
    end
  end
  def adaptive_tx=(value)
    ethtool_setonoff('adaptive_tx', '-C', 'adaptive-tx', value)
  end

  %w{rx-usecs rx-frames rx-usecs-irq rx-frames-irq tx-usecs tx-frames tx-usecs-irq tx-frames-irq
     stats-block-usecs pkt-rate-low rx-usecs-low rx-frames-low tx-usecs-low tx-frames-low pkt-rate-high
     rx-usecs-high rx-frame-high tx-usecs-high tx-frame-high sample-interval}.each do |arg|
    get_method = arg.gsub(/-/, '_')
    define_method get_method do
      answer = ethtool('-c', resource[:name]).split(/\n/).find { |line| line =~ Regexp.new(arg) }
      puts answer
      if answer
        answer.split(/: /)[1]
      else
        'unknown'
      end
    end
    define_method("#{get_method}=") do |value|
      if value =~ /^\d$/
        ethtool(get_method, '-C', arg, value)
      else
        raise("get_method setting should be an integer, not #{value}")
      end
    end
  end

  private
  def ethtool_setonoff(human_name, ethtool_arg, ethtool_name, value)
    setting = case value
    when :enabled
      'on'
    when :disabled
      'off'
    else
      raise("#{human_name} setting should be enabled or disabled, not #{value}")
    end
    ethtool(ethtool_arg, resource[:name], ethtool_name, setting) 
  end
end

