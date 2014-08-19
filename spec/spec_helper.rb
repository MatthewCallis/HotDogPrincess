require 'rubygems'
require 'yaml'
require 'rspec'

RSpec.configure do |config|
  config.before :suite do
    options = YAML.load_file 'spec/hotdogprincess.yml'
    @options = Hash[ options.keys.collect(&:to_sym).zip options.values ]
    HotDogPrincess.client @options

    require './spec/vcr_setup.rb'
  end
end
