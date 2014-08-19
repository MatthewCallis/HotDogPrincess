require 'spec_helper'
require 'hotdogprincess'

describe "HotDogPrincess::Client::Tickets" do
  include HotDogPrincess

  describe "Tickets" do

    it "can get all tickets" do
      VCR.use_cassette 'client.tickets' do
        tickets = HotDogPrincess.client.tickets
        expect(tickets).not_to eq(nil)
        expect(HotDogPrincess.client.ticket_count).to be > 0
      end
    end

    it "can get a single ticket" do
      VCR.use_cassette 'client.tickets' do
        @tickets = HotDogPrincess.client.tickets
      end

      target = @tickets.first
      VCR.use_cassette 'client.ticket' do
        @ticket = HotDogPrincess.client.ticket target.id
      end

      expect(@ticket.department).not_to eq(nil)
      expect(@ticket.id).to eq target.id
      expect(@ticket.uid).to eq "#{HotDogPrincess.client.account_id}/#{@ticket.department.id}/Ticket/#{target.id}"
      expect(@ticket.href).to eq "https://#{HotDogPrincess.client.host}/api/v1/#{HotDogPrincess.client.account_id}/#{@ticket.department.id}/Ticket/#{target.id}"
    end
  end

end
