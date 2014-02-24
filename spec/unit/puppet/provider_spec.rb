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

  ['centos5_1', 'ubuntulucid_1'].each do |fixture_name|
    %w{tso ufo gro gso}.each do |type|
      it "can detect #{type} on #{name}" do
        load_fix('k', fixture_name)
        expect(provider.send(type.to_sym)).to eql('disabled')
      end
    end
  end

  it "can NOT detect lro on centos5_1" do
    load_fix('k', 'centos5_1')
    expect(provider.lro).to eql('unknown')
  end

  it "can detect lro on ubuntulucid_1" do
    load_fix('k', 'ubuntulucid_1')
    expect(provider.lro).to eql('disabled')
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

