require 'facter'
require 'facter/util/ip'

Facter::Util::IP.get_interfaces.each do |interface|
  speedline = `ethtool #{interface} | grep Speed`
  if speedline =~ /Speed: \d+Mb\/s/
    speed = /Speed: (\d+)Mb\/s/.match(speedline)[1]
    Facter.add('speed_' + Facter::Util::IP.alphafy(interface)) do
      setcode do
        speed
      end
    end
  end
end

