require 'spec_helper'
require 'facter/util/ip'

describe "Interface Speed Fact" do

  context "On linux when ethtool works" do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:virtual).stubs(:value).returns("physical")
      Facter::Util::Resolution.stubs(:exec)
      Facter::Util::Resolution.stubs(:exec).with("ethtool testeth 2>/dev/null | grep Speed").returns("	Speed: 42Mb/s")
      Facter::Util::IP.stubs(:get_interfaces).returns( ['testeth'] )
    end
    it "Should report back just the number in Mb/s" do
      Facter.fact(:speed_testeth).value.should == '42'
    end
  end

  context "On linux when ethtool doesn't work" do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:virtual).stubs(:value).returns("physical")
      Facter::Util::Resolution.stubs(:exec)
      Facter::Util::Resolution.stubs(:exec).with("ethtool testeth 2>/dev/null | grep Speed").returns("")
      Facter::Util::IP.stubs(:get_interfaces).returns( ['testeth'] )
    end
    it "The fact shouldn't be there" do
      Facter.fact(:speed_testeth).should == nil
    end
  end

  context "On an unsupported OS" do
    before do
      Facter.fact(:kernel).stubs(:value).returns(:windows)
      Facter.fact(:kernelrelease).stubs(:value).returns('6.1.7601')
      Facter::Util::IP.stubs(:get_interfaces).returns(['WINDOWS_INTERFACE'])
    end
    it "Should not have a fact" do
      Facter.fact(:speed_WINDOWS_INTERFACE).should == nil
    end
  end

  after :each do
    # Make sure we're clearing out Facter every time
    Facter.clear
    Facter.clear_messages
  end

end
