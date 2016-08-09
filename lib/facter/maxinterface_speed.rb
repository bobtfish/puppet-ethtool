if File.exists?('/sbin/ethtool')
  Dir.foreach('/sys/class/net').each do |interface|
    next if interface.start_with?('veth')
    Facter.debug("Running ethtool on interface #{interface}")
    linkmodes = %x{/sbin/ethtool #{interface} 2>/dev/null}.scan(/Supported link modes:[^:]*/m).first
    max = linkmodes && linkmodes.scan(/\d+/).map(&:to_i).max
    if max
      Facter.add('maxspeed_' + interface.gsub(/[^a-z0-9_]/i, '_')) do
        confine :kernel => "Linux"
        setcode do
          max.to_s
        end
      end
    end
  end
end
