#!/usr/bin/env rspec
#
require 'spec_helper'

type_class = Puppet::Type.type(:ethtool)
provider_class = type_class.provider(:linux)

describe type_class do

  let(:type) do
    Puppet::Type.type(:ethtool).new(
      :name => 'eth0',
      :lro => 'enabled',
      :ignore_unknown => true,
      :provider => 'linux',
    )
  end
  let(:provider) do
    provider_class.new
  end
  subject do
    provider.resource = type
    type
  end

  it "can be in sync desptite inability to detect lro on centos5_1" do
    subject.provider.stubs(:ethtool).returns(
      IO.read("#{File.dirname(__FILE__)}/../../fixtures/ethtool_outputs/k/centos5_1.txt")
    )
    p = subject.properties.find { |prop| prop.name == :lro }
    expect(p.retrieve).to eql('unknown')
    expect(p.insync?('unknown')).to eql(true)
  end
end

