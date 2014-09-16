require 'facter/util/ip'

Facter::Util::IP.get_interfaces.each do |interface|
  Facter.debug("Running ethtool on interface #{interface}")
  out = Facter::Util::Resolution.exec("ethtool #{interface} 2>/dev/null")
  if !out.nil?
    out = out.sub(/.*Supported link modes:/m, '')
    max = 0
    out.sub(/:.*/m, '').split(/\s+/m).select { |i| i =~ /\d+base/ }.map { |i| i.sub(/base.*/, '') }.each do |speed|
      speed = speed.to_i
      if speed > max
        max = speed
      end
    end
    Facter.add('maxspeed_' + Facter::Util::IP.alphafy(interface)) do
      confine :kernel => "Linux"
      setcode do
        max.to_s
      end
    end
  end
end

