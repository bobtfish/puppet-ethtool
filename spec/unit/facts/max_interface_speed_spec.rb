require 'spec_helper'
require 'facter/util/ip'

describe "Max Interface Speed Fact" do

  context "On linux when ethtool works 1G" do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:virtual).stubs(:value).returns("physical")
      Facter::Util::Resolution.stubs(:exec)
      Facter::Util::Resolution.stubs(:exec).with("ethtool testeth 2>/dev/null").returns("Settings for testeth:
    Supported ports: [ TP ]
    Supported link modes: 10baseT/Half 10baseT/Full
    100baseT/Half 100baseT/Full
    1000baseT/Full
    Supports auto-negotiation: Yes
    Advertised link modes: 10baseT/Half 10baseT/Full
    100baseT/Half 100baseT/Full
    1000baseT/Full
    Advertised pause frame use: Symmetric
    Advertised auto-negotiation: Yes
    Link partner advertised link modes: Not reported
    Link partner advertised pause frame use: No
    Link partner advertised auto-negotiation: No
    Speed: Unknown!
    Duplex: Unknown! (255)
    Port: Twisted Pair
    PHYAD: 1
    Transceiver: internal
    Auto-negotiation: on
    MDI-X: off
    Supports Wake-on: pumbg
    Wake-on: d
    Current message level: 0x00000007 (7)
    Link detected: no
")
      Facter::Util::IP.stubs(:get_interfaces).returns( ['testeth'] )
    end
    it "Should report back just the number in Mb/s" do
      Facter.fact(:maxspeed_testeth).value.should == '1000'
    end
  end

  context "On linux when ethtool works 10G" do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:virtual).stubs(:value).returns("physical")
      Facter::Util::Resolution.stubs(:exec)
      Facter::Util::Resolution.stubs(:exec).with("ethtool testeth 2>/dev/null").returns("Settings for eth2:
      Supported ports: [ FIBRE ]
      Supported link modes: 10000baseT/Full
      Supports auto-negotiation: No
      Advertised link modes: 10000baseT/Full
      Advertised pause frame use: No
      Advertised auto-negotiation: No
      Link partner advertised link modes: Not reported
      Link partner advertised pause frame use: No
      Link partner advertised auto-negotiation: No
      Speed: 10000Mb/s
      Duplex: Full
      Port: Direct Attach Copper
      PHYAD: 0
      Transceiver: external
      Auto-negotiation: off
      Supports Wake-on: umbg
      Wake-on: g
      Current message level: 0x00000007 (7)
      Link detected: yes")
      Facter::Util::IP.stubs(:get_interfaces).returns( ['testeth'] )
          end
      it "Should report back just the number in Mb/s" do
          Facter.fact(:maxspeed_testeth).value.should == '10000'
      end
  end

  after :each do
    # Make sure we're clearing out Facter every time
    Facter.clear
    Facter.clear_messages
  end

end
