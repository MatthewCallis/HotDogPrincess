require 'spec_helper'
require 'hotdogprincess'
require 'faker'

describe "HotDogPrincess::Client::Customers" do
  include HotDogPrincess

  describe "Customers" do
    it "can get all customers as an array of hashes" do
      VCR.use_cassette 'client.customers' do
        customers = HotDogPrincess.client.customers
        expect(customers).not_to eq(nil)
        expect(HotDogPrincess.client.customer_count).to be > 0
      end
    end

    it "can get all customers as raw returned JSON/XML" do
      VCR.use_cassette 'client.customers' do
        customers = HotDogPrincess.client.customers_raw
        expect(customers).not_to eq(nil)
        expect(HotDogPrincess.client.customer_count).to be > 0
      end
    end

    it "can get a single customer" do
      VCR.use_cassette 'client.customers' do
        @customers = HotDogPrincess.client.customers
      end

      target = @customers.first
      VCR.use_cassette 'client.customer' do
        @customer = HotDogPrincess.client.customer target[:id]
      end

      expect(@customer[:id]).to eq target[:id]
      expect(@customer[:uid]).to eq "#{HotDogPrincess.client.account_id}/#{HotDogPrincess.client.department_id}/Customer/#{target[:id]}"
      expect(@customer[:href]).to eq "https://#{HotDogPrincess.client.host}/api/v1/#{HotDogPrincess.client.account_id}/#{HotDogPrincess.client.department_id}/Customer/#{target[:id]}"
      expect(@customer[:first_name]).not_to be nil
      expect(@customer[:last_name]).not_to be nil
      expect(@customer[:email]).not_to be nil
    end

    it "can create a customer" do
      customer = { 'Customer' => {
          'First_Name' => 'John',
          'Last_Name' => 'Doe',
          'Email' => Faker::Internet.email,
          'Password' => 'password',
          'Password_Confirm' => 'password'
        }
      }

      VCR.use_cassette 'client.create_customer' do
        response = HotDogPrincess.client.create_customer customer
        expect(response).not_to be nil
      end
    end

    describe '#find_customer_by_email' do
      it 'returns nil for an empty search' do
        VCR.use_cassette 'client.client.find_customer_by_email nil' do
          response = HotDogPrincess.client.find_customer_by_email "invalid@invalid.invalid"
          expect(response.class).to eq Array
          expect(response).to eq []
        end
      end

      it 'returns and array for a search with results' do
        VCR.use_cassette 'client.client.find_customer_by_email valie' do
          response = HotDogPrincess.client.find_customer_by_email "joe", true
          expect(response.class).to eq Array
          expect(response).not_to eq []
        end
      end
    end

  end
end
