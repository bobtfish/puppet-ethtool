require 'facter'
require 'socket'
require 'json'
Socket.getifaddrs.each do |ifaddr|
  interface = ifaddr.name
  next if interface.start_with?('veth') || interface.include?('lo') || ! File.exists?('/sbin/ethtool')
  Facter.debug("Running ethtool on interface #{interface}")
  data = {}
  Facter::Util::Resolution.exec("ethtool -i #{interface} 2>/dev/null").split(/\n/).each do |line|
    k, v = line.split(': ')
    if v
     data[k]=v
    end
  end
  if data['driver']
    Facter.add('driver_' + interface) do
      confine :kernel => "Linux"
      setcode do
        data['driver']
      end
    end
  end
  if data['version']
    Facter.add('driver_version_' + interface) do
      confine :kernel => "Linux"
      setcode do
        data['version']
      end
    end
  end
end
