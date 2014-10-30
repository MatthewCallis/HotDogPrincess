require 'spec_helper'
require 'hotdogprincess'

describe "HotDogPrincess::CoreExtensions::Hash" do
  include HotDogPrincess

  describe "compact" do
    it "own the method" do
      expect({}.method(:compact).owner).to eq HotDogPrincess::CoreExtensions::Hash
      expect(Hash.ancestors).to include(HotDogPrincess::CoreExtensions::Hash)
    end

    it "recursively removes nil values from the hash" do
      expect({ test: 'test', blank: nil, next: 123 }.compact).to eq({ test: 'test', next: 123 })
      expect({ test: 'test', blank: nil, next: 123, nested: { neat: 'string', blah: nil} }.compact).to eq({ test: 'test', next: 123, nested: { neat: 'string'} })
      expect({ test: 'test', blank: nil, next: 123, nested: { blah: nil} }.compact).to eq({:test=>"test", :next=>123})
    end
  end

end
