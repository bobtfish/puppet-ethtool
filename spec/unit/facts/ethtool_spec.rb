require 'spec_helper'
require 'facter/ethtool'

describe Ethtool::Facts do

  describe '#exists?' do
    it 'returns true if ethtool is installed' do
      File.stubs(:exists?).returns(true)
      expect(Ethtool::Facts.exists?).to eq(true)
    end

    it 'returns false if ethtool is not installed' do
      File.stubs(:exists?).returns(false)
      expect(Ethtool::Facts.exists?).to eq(false)
    end
  end

  describe '#interfaces' do
    it 'returns an array of interfaces without parent directories or virtual interfaces' do
      Dir.stubs(:foreach).returns(['.', '..', 'eth0', 'lo', 'veth0'])
      expect(Ethtool::Facts.interfaces).to eq(['eth0', 'lo'])
    end
  end

  describe '#alphafy' do
    it 'replaces non alphanumeric characters' do
      expect(Ethtool::Facts.alphafy('eth0.10')).to eq('eth0_10')
    end
  end

  describe '#gather' do
    it 'returns a hash of interfaces and their speeds' do
      Ethtool::Facts.stubs(:interfaces).returns(['enp0s25', 'vboxnet0'])
      Ethtool::Facts.stubs(:ethtool).with('enp0s25').
          returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/ethtool_outputs/enp0s25.txt"))
      Ethtool::Facts.stubs(:ethtool).with('enp0s25', '-i').
          returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/ethtool_outputs/i/ubuntuxenial.txt"))
      Ethtool::Facts.stubs(:ethtool).with('vboxnet0').
          returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/ethtool_outputs/vboxnet0.txt"))
      Ethtool::Facts.stubs(:ethtool).with('vboxnet0', '-i').
          returns(IO.read("#{File.dirname(__FILE__)}/../../fixtures/ethtool_outputs/i/ubuntuxenial.txt"))

      expect(Ethtool::Facts.gather).to eq({
                                              'enp0s25' => {'max_speed' => 1000,
                                                            'driver' => 'ath10k_pci',
                                                            'driver_version' => '4.4.0-77-generic', },
                                              'vboxnet0' => {'speed' => 10,
                                                             'driver' => 'ath10k_pci',
                                                             'driver_version' => '4.4.0-77-generic', }
                                          })
    end
  end

  context "On linux when ethtool works" do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Ethtool::Facts.stubs(:exists?).returns(true)
      Ethtool::Facts.stubs(:interfaces).returns(['testeth'])
      Ethtool::Facts.stubs(:ethtool).returns('  Speed: 42Mb/s')
      Ethtool::Facts.facts
    end
    it "Should report back just the number in Mb/s" do
      expect(Facter.fact(:speed_testeth).value).to eq('42')
    end
  end

  context "On linux when ethtool doesn't work" do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Ethtool::Facts.stubs(:exists?).returns(true)
      Ethtool::Facts.stubs(:interfaces).returns(['testeth'])
      Ethtool::Facts.stubs(:ethtool).returns('')
      Ethtool::Facts.facts
    end
    it "The fact shouldn't be there" do
      expect(Facter.fact(:speed_testeth)).to be_nil
    end
  end

  context "On an unsupported OS" do
    before do
      Facter.fact(:kernel).stubs(:value).returns('windows')
      Facter.fact(:kernelrelease).stubs(:value).returns('6.1.7601')
      Ethtool::Facts.stubs(:exists?).returns(true)
      Ethtool::Facts.stubs(:interfaces).returns(['WINDOWS_INTERFACE'])
      Ethtool::Facts.facts
    end
    it "Should not have a fact" do
      expect(Facter.fact(:speed_WINDOWS_INTERFACE)).to be_nil
    end
  end

  after :each do
    # Make sure we're clearing out Facter every time
    Facter.clear
    Facter.clear_messages
  end

end
