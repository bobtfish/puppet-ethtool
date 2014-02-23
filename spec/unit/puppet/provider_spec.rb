#!/usr/bin/env rspec
#
require 'spec_helper'

provider_class = Puppet::Type.type(:ethtool).provider(:linux)

describe provider_class do
  let(:resource) do
    Puppet::Type.type(:ethtool).new(
      :name => 'eth0',
      :tso => 'enabled',
      :provider => 'linux',
    )
  end

  let(:provider) do
    provider = provider_class.new
    provider.resource = resource
    provider
  end

  def load_fix(type, name)
    provider.expects(:ethtool).with("-#{type}", 'eth0').returns(IO.read("#{File.dirname(__FILE__)}/../../../fixtures/ethtool_outputs/#{type}/#{name}.txt"))
  end

  ['centos5_1', 'ubuntulucid_1'].each do |name|
    it "Be able to detect TSO on #{name}" do
      load_fix('k', name)
      expect(provider.tso).to eql('disabled')
    end
  end

  it "Be able to enable TSO" do
    provider.expects(:ethtool).with("-K", 'eth0', 'tso', 'on')
    expect { provider.tso = :enabled }.not_to raise_error
  end

  it "Be able to disable TSO" do
    provider.expects(:ethtool).with("-K", 'eth0', 'tso', 'off')
    expect { provider.tso = :disabled }.not_to raise_error
  end

end

