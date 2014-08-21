require 'spec_helper'
require 'hotdogprincess'

describe "HotDogPrincess::Client" do
  include HotDogPrincess

  let(:host) { 'sandbox.parature.com' }
  let(:account_id) { 1 }
  let(:department_id) { 2 }
  let(:token) { 'token' }
  let(:client) { ::HotDogPrincess::Client.new(
    host: host,
    account_id: account_id,
    department_id: department_id,
    token: token
  ) }

  it "can create a client" do
    expect(client).not_to eq nil
  end

  describe "RestClient Methods" do
    # def get(path, options = {})
    #   url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}"
    #   options = {
    #     _output_: @output_format,
    #     _token_: @token
    #   }.merge(options)
    #   @last_response = RestClient.get url, { params: options }
    #   clean_response @last_response
    # end
    before do
      VCR.use_cassette 'client.tickets' do
        @tickets = HotDogPrincess.client.tickets
      end
      @target = @tickets.first
    end

    it "get" do
      VCR.use_cassette 'client.ticket get' do
        ticket = HotDogPrincess.client.get "Ticket/#{@target[:id]}"
        expect(ticket).not_to eq nil
        expect(ticket["?xml"]).not_to eq nil
      end
    end
    # Need to mock these.
    # it "post" do
    # Returns a 201 created on success
    # <?xml version="1.0" encoding="utf-8" ?><Ticket id="" uid="" href="" service-desk-uri="" />
    #   VCR.use_cassette 'client.ticket post' do
    #     ticket = HotDogPrincess.client.post 'Ticket', nil
    #     expect(ticket).not_to eq nil
    #   end
    # end
    # it "put" do
    # More required fields than on post
    #   VCR.use_cassette 'client.ticket put' do
    #     ticket = HotDogPrincess.client.put "Ticket/#{@target[:id]}", nil
    #     expect(ticket).not_to eq nil
    #   end
    # end
    # it "delete" do
    # Returns a 204 no content on success
    #   VCR.use_cassette 'client.ticket delete' do
    #     ticket = HotDogPrincess.client.delete "Ticket/#{@target[:id]}"
    #     expect(ticket).not_to eq nil
    #   end
    # end
  end

  it "can set and get host" do
    new_host = 'coolersandbox.com'
    expect(client.host).to eq host
    client.host = new_host
    expect(client.host).to eq new_host
  end

  it "can set and get token" do
    new_token = 'valid=='
    expect(client.token).to eq token
    client.token = new_token
    expect(client.token).to eq new_token
  end

  it "can set and get account_id" do
    new_account_id = 111
    expect(client.account_id).to eq account_id
    client.account_id = new_account_id
    expect(client.account_id).to eq new_account_id
  end

  it "can set and get department_id" do
    new_department_id = 222
    expect(client.department_id).to eq department_id
    client.department_id = new_department_id
    expect(client.department_id).to eq new_department_id
  end

  it "#last_response" do
    VCR.use_cassette('client.schema Ticket') do
      HotDogPrincess.client.schema('Ticket')
    end
    expect(HotDogPrincess.client.last_response).not_to eq nil
  end

  describe "#clean_response" do
    let(:sla_schema) { {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}, "Sla"=>{"Name"=>{"@display-name"=>"Name", "@required"=>"true", "@editable"=>"false", "@field-type"=>"text", "@data-type"=>"string", "@max-length"=>"32"}}} }
    it "cleans bad responses" do
      responses = "\xEF\xBB\xBF".b << '{
                    "?xml": {
                      "@version": "1.0",
                      "@encoding": "utf-8"
                    },
                    "Sla": {
                      "Name": {
                        "@display-name": "Name",
                        "@required": "true",
                        "@editable": "false",
                        "@field-type": "text",
                        "@data-type": "string",
                        "@max-length": "32"
                      }
                    }
                  }'
      clean_response = client.clean_response responses
      expect(clean_response).to eq sla_schema
    end

    it "accepts good responses" do
      responses = '{
                    "?xml": {
                      "@version": "1.0",
                      "@encoding": "utf-8"
                    },
                    "Sla": {
                      "Name": {
                        "@display-name": "Name",
                        "@required": "true",
                        "@editable": "false",
                        "@field-type": "text",
                        "@data-type": "string",
                        "@max-length": "32"
                      }
                    }
                  }'
      clean_response = client.clean_response responses
      expect(clean_response).to eq sla_schema
    end
  end

  it "#schema" do
    VCR.use_cassette('client.schema Ticket') do
      @schema = HotDogPrincess.client.schema('Ticket')
    end
    expect(@schema).not_to eq nil
    expect(@schema.class).to eq Hash
  end

  it "#schema_json" do
    VCR.use_cassette('client.schema Ticket') do
      @schema = HotDogPrincess.client.schema_json('Ticket')
    end
    expect(@schema).not_to eq nil
    expect(@schema.class).to eq String
    expect(JSON.parse(@schema).class).to eq Hash
  end
end
