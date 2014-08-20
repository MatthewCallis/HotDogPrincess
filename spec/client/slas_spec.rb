require 'spec_helper'
require 'hotdogprincess'

describe "HotDogPrincess::Client::Slas" do
  include HotDogPrincess

  describe "Slas" do
    it "can get all slas as an array of hashes" do
      VCR.use_cassette 'client.slas' do
        slas = HotDogPrincess.client.slas
        expect(slas).not_to eq(nil)
        expect(HotDogPrincess.client.sla_count).to be > 0
      end
    end

    it "can get all slas as raw returned JSON/XML" do
      VCR.use_cassette 'client.slas' do
        slas = HotDogPrincess.client.slas_raw
        expect(slas).not_to eq(nil)
        expect(HotDogPrincess.client.sla_count).to be > 0
      end
    end

    it "can get a single sla" do
      VCR.use_cassette 'client.slas' do
        @slas = HotDogPrincess.client.slas
      end

      target = @slas.first
      VCR.use_cassette 'client.sla' do
        @sla = HotDogPrincess.client.sla target.id
      end

      expect(@sla.name).not_to eq(nil)
      expect(@sla.id).to eq target.id
      expect(@sla.uid).to eq "#{HotDogPrincess.client.account_id}/#{HotDogPrincess.client.department_id}/Sla/#{target.id}"
      expect(@sla.href).to eq "https://#{HotDogPrincess.client.host}/api/v1/#{HotDogPrincess.client.account_id}/#{HotDogPrincess.client.department_id}/Sla/#{target.id}"
    end
  end
end
