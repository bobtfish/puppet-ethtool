require 'spec_helper'

describe 'ethtool', :type => :class do

  it { should compile }
  
  context "By default" do
    it { should contain_package('ethtool').with_ensure('present') }
  end
  
  context "When asked not to install ethtool" do
    let(:params){{ :ensure_installed => false }}
    it { should_not contain_package('ethtool').with_ensure('present') }
  end

end
