require 'spec_helper'
require 'hotdogprincess'

describe "HotDogPrincess" do
  include HotDogPrincess

  it "can load config" do
    expect(HotDogPrincess.client).not_to eq(nil)
  end

  it "can set and get host" do
    host = 'coolersandbox.com'
    expect(HotDogPrincess.client).not_to eq(nil)
  end

  it "can fetch valid schemas" do
    VCR.use_cassette('client.schema Sla') do
      expect(HotDogPrincess.client.schema('Sla')).not_to eq(nil)
    end
    VCR.use_cassette('client.schema Customer') do
      expect(HotDogPrincess.client.schema('Customer')).not_to eq(nil)
    end
    VCR.use_cassette('client.schema Ticket') do
      expect(HotDogPrincess.client.schema('Ticket')).not_to eq(nil)
    end
  end

end
