source "http://rubygems.org"

group :test do
  gem "rake"
  gem "json", RUBY_VERSION == '1.9.3' && '< 2.0.0' || nil
  gem "json_pure", RUBY_VERSION == '1.9.3' && '< 2.0.0' || nil
  gem "puppet", ENV['PUPPET_VERSION']
  gem "puppet-lint"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "metadata-json-lint"
  gem "puppetlabs_spec_helper"
  gem "semantic_puppet"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "puppet-blacksmith"
end
