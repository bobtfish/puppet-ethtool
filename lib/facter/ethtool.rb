require 'shellwords'

module Ethtool
  module Facts

    # Check whether ethtool exists
    def self.exists?
      File.exists?('/usr/sbin/ethtool')
    end

    # Run ethtool on an interface
    def self.ethtool(interface, option='')
      %x{/usr/sbin/ethtool #{option} #{Shellwords.escape(interface)}  2>/dev/null}
    end

    # Get all interfaces on the system
    def self.interfaces
      Dir.foreach('/sys/class/net').reject {|x| x.start_with?('.', 'veth')}
    end

    # Convert raw interface names into a canonical version
    def self.alphafy str
      str.gsub(/[^a-z0-9_]/i, '_')
    end

    # Parse ethtool output for all interfaces
    def self.gather
      interfaces.inject({}) do |interfaces, interface|
        output = ethtool(interface)
        output_i = ethtool(interface, '-i')

        metrics = {}

        # Extract the interface speed
        speedline = output.split("\n").detect {|x| x.include?('Speed:')}
        speed = speedline && speedline.scan(/\d+/).first
        metrics['speed'] = speed.to_i if speed

        # Extract the interface max speed
        linkmodes = output.scan(/Supported link modes:[^:]*/m).first
        max_speed = linkmodes && linkmodes.scan(/\d+/).map(&:to_i).max
        metrics['max_speed'] = max_speed.to_i if max_speed

        # Extract the interface driver info
        driver_line = output_i.match(/^driver:\s+(?<driver>.*)/)
        metrics['driver'] = driver_line[:driver].to_s if driver_line

        # Extract the interface driver info
        driver_version_line = output_i.match(/^version:\s+(?<version>.*)/)
        metrics['driver_version'] = driver_version_line[:version].to_s if driver_version_line

        # Gather the interface statistics
        next interfaces if metrics.empty?
        interfaces[alphafy(interface)] = metrics
        interfaces
      end
    end

    # Gather all facts
    def self.facts
      # Ethtool isn't installed, don't collect facts
      return if !exists?

      ifstats = gather

      # Structured facts
      Facter.add('ethtool_interfaces') do
        confine :kernel => 'Linux'
        setcode do
          ifstats
        end
      end

      # Legacy facts
      ['speed', 'maxspeed', 'driver', 'driver_version'].each do |fact_name|
        ifstats.each do |interface, data|
          next unless data[fact_name]
          Facter.add("#{fact_name}_" + interface) do
            confine :kernel => 'Linux'
            setcode do
              # Backwards compatibility
              if fact_name == 'maxspeed'
                data['max_speed'].to_s
              else
                data[fact_name].to_s
              end
            end
          end
        end
      end
    end
  end
end

Ethtool::Facts.facts
