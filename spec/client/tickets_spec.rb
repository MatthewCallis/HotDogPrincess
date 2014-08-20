require 'spec_helper'
require 'hotdogprincess'

describe "HotDogPrincess::Client::Tickets" do
  include HotDogPrincess

  describe "Tickets" do
    it "can get all tickets as an array of hashes" do
      VCR.use_cassette 'client.tickets' do
        tickets = HotDogPrincess.client.tickets
        expect(tickets).not_to eq(nil)
        expect(HotDogPrincess.client.ticket_count).to be > 0
      end
    end

    it "can get all tickets as raw returned JSON/XML" do
      VCR.use_cassette 'client.tickets' do
        tickets = HotDogPrincess.client.tickets_raw
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

    it "can create a ticket" do
      ticket = { "Ticket" => {
          "Ticket_Customer" => {
            "Customer/" => {
              :@id => "10002"
            }
          },
          "Custom_Field" => [
            {
              :@id => "81",
              "Option/" => {
                :@id => "57",
                :@selected =>"true"
              }
            },
            {
              :@id => "84",
              "Option/" => {
                :@id => "160",
                :@selected =>"true"
              }
            },
            {
              :@id => "85",
              :content! => "Notes: It's Godzilla, no it's Apptentive!"
            },
            {
              :@id => "80",
              "Option/" => {
                :@id => "44",
                :@selected =>"true"
              }
            },
            {
              :@id => "39",
              "Option/" => {
                :@id => "11",
                :@selected =>"true"
              }
            },
            {
              :@id => "82",
              "Option/" => {
                :@id => "69",
                :@selected =>"true"
              }
            },
            {
              :@id => "88",
              :content! => "Status: Working?"
            }
          ]
        }
      }

      VCR.use_cassette 'client.create_ticket' do
        response = HotDogPrincess.client.create_ticket ticket
        expect(response).not_to be nil
      end
    end
  end
end
