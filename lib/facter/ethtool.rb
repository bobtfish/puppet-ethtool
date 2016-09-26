require 'shellwords'

module Ethtool
  module Facts

    # Check whether ethtool exists
    def self.exists?
      File.exists?(ethtool_path)
    end

    def self.ethtool_path
      File.exists?('/usr/sbin/ethtool') ? '/usr/sbin/ethtool' : '/sbin/ethtool'
    end

    # Run ethtool on an interface
    def self.ethtool(interface)
      %x{#{ethtool_path} #{Shellwords.escape(interface)} 2>/dev/null}
    end

    def self.ethtool_i(interface)
      %x{#{ethtool_path} -i #{Shellwords.escape(interface)} 2>/dev/null}
    end

    # Get all interfaces on the system
    def self.interfaces
      Dir.foreach('/sys/class/net').reject{|x| x.start_with?('.', 'veth')}
    end

    # Convert raw interface names into a canonical version
    def self.alphafy str
      str.gsub(/[^a-z0-9_]/i, '_')
    end

    # Parse ethtool output for all interfaces
    def self.gather
      interfaces.inject({}) do |interfaces, interface|

        data = {}
        ethtool_i(interface).split("\n").each do |line|
          k, v = line.split(': ')
          if v
            data[k]=v
          end
        end

        output = ethtool(interface)

        metrics = {}
        if data['driver']
          metrics['driver'] = data['driver']
        end
        if data['version']
          metrics['driver_version'] = data['version']
        end

        # Extract the interface speed
        speedline = output.split("\n").detect{|x| x.include?('Speed:')}
        speed = speedline && speedline.scan(/\d+/).first
        metrics['speed'] = speed.to_i if speed

        # Extract the interface max speed
        linkmodes = output.scan(/Supported link modes:[^:]*/m).first
        max_speed = linkmodes && linkmodes.scan(/\d+/).map(&:to_i).max
        metrics['max_speed'] = max_speed.to_i if max_speed

        # Gather the interface statistics
        next interfaces if metrics.empty?
        interfaces[alphafy(interface)] = metrics
        interfaces
      end
    end

    # Gather all facts
    def self.facts
      # Ethtool isn't installed, don't collect facts
      return if ! exists?

      ifstats = gather

      # Structured facts
      Facter.add('ethtool_interfaces') do
        confine :kernel => 'Linux'
        setcode do
          ifstats
        end
      end

      # Legacy facts
      ifstats.each do |interface, data|
        next unless data['speed']
        Facter.add('speed_' + interface) do
          confine :kernel => 'Linux'
          setcode do
            # Backwards compatibility
            data['speed'].to_s
          end
        end
      end

      ifstats.each do |interface, data|
        next unless data['max_speed']
        Facter.add('maxspeed_' + interface) do
          confine :kernel => 'Linux'
          setcode do
            # Backwards compatibility
            data['max_speed'].to_s
          end
        end
      end

      ifstats.each do |interface, data|
        next unless data['driver']
        Facter.add('driver_' + interface) do
          confine :kernel => 'Linux'
          setcode do
            data['driver'].to_s
          end
        end
      end

      ifstats.each do |interface, data|
        next unless data['driver_version']
        Facter.add('driver_version_' + interface) do
          confine :kernel => 'Linux'
          setcode do
            data['driver_version'].to_s
          end
        end
      end
    end

  end
end

Ethtool::Facts.facts
