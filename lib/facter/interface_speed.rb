require 'facter/util/ip'

Facter::Util::IP.get_interfaces.each do |interface|
  Facter.debug("Running ethtool on interface #{interface}")
  speedline = Facter::Util::Resolution.exec("ethtool #{interface} 2>/dev/null | grep Speed")
  if speedline =~ /Speed: \d+Mb\/s/
    speed = /Speed: (\d+)Mb\/s/.match(speedline)[1]
    Facter.add('speed_' + Facter::Util::IP.alphafy(interface)) do
      confine :kernel => "Linux"
      setcode do
        speed
      end
    end
  else
    Facter.debug("Running ethtool on #{interface} didn't give any Speed line")
  end
end

