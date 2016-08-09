if File.exists?('/sbin/ethtool')
  Dir.foreach('/sys/class/net').each do |interface|
    Facter.debug("Running ethtool on interface #{interface}")
    speedline = %x{/sbin/ethtool #{interface} 2>/dev/null}.split("\n").detect{|x| x.include?('Speed:')}
    speed = speedline && speedline.scan(/\d+/).first
    if speed
      Facter.add('speed_' + interface.gsub(/[^a-z0-9_]/i, '_')) do
        confine :kernel => "Linux"
        setcode do
          speed
        end
      end
    else
      Facter.debug("Running ethtool on #{interface} didn't give any Speed line")
    end
  end
end
