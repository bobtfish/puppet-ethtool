require 'facter'
require 'facter/util/ip'
require 'json'
Facter::Util::IP.get_interfaces.each do |interface|
  next if interface.start_with?('veth')
  Facter.debug("Running ethtool on interface #{interface}")
  data = {}
  Facter::Util::Resolution.exec("ethtool -i #{interface} 2>/dev/null").split("\n").each do |line|
    k, v = line.split(': ')
    if v
     data[k]=v
    end
  end
  if data['driver']
    Facter.add('driver_' + Facter::Util::IP.alphafy(interface)) do
      confine :kernel => "Linux"
      setcode do
        data['driver']
      end
    end
  end
  if data['version']
    Facter.add('driver_version' + Facter::Util::IP.alphafy(interface)) do
      confine :kernel => "Linux"
      setcode do
        data['version']
      end
    end
  end
end
