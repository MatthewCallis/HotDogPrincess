require 'gyoku'
require 'ostruct'

module HotDogPrincess
  class Client
    module Tickets

      @tickets = nil
      @tickets_raw = nil

      def fetch_tickets(page_size = 100)
        @tickets_raw = get "Ticket", _pageSize_: page_size
        @tickets_raw
      end

      def tickets(page_size = 100, force_update = false)
        return @tickets  if @tickets and !force_update
        fetch_tickets(page_size)
        return nil  unless @tickets_raw
        @tickets ||= []
        @tickets_raw["Entities"]["Ticket"].each do |ticket|
          @tickets.push parse_ticket ticket
        end
        @tickets
      end

      def tickets_raw
        @tickets
      end

      def ticket_count
        return @tickets.length  if @tickets
        return @tickets["Entities"].length  if @tickets_raw
        0
      end

      def tickets_since(start_date, page_size = 100)
        @tickets = get "Ticket", _pageSize_: page_size, Date_Created: start_date
        @tickets["Entities"]
      end

      def ticket(ticket_id, history = false)
        ticket = get "Ticket/#{ticket_id}", _history_: history
        parse_ticket ticket['Ticket']
      end

      def create_ticket(*args)
        xml = Gyoku.xml(args[:ticket])
        post "Ticket", xml
      end

      def parse_ticket(ticket)
        # Meta
        clean_ticket = OpenStruct.new
        clean_ticket.id               = ticket['@id']
        clean_ticket.uid              = ticket['@uid']
        clean_ticket.href             = ticket['@href']
        clean_ticket.service_desk_uri = ticket['@service-desk-uri']

        # Dates
        clean_ticket.date_created = Time.parse(ticket['Date_Created']['#text']).utc.to_date
        clean_ticket.date_updated = Time.parse(ticket['Date_Updated']['#text']).utc.to_date

        # Booleans
        clean_ticket.dont_overwrite_sla_in_rr              = ticket['Dont_Overwrite_Sla_In_Rr']['#text'].downcase == 'true'
        clean_ticket.email_notification                    = ticket['Email_Notification']['#text'].downcase == 'true'
        clean_ticket.email_notification_additional_contact = ticket['Email_Notification_Additional_Contact']['#text'].downcase == 'true'
        clean_ticket.hide_from_customer                    = ticket['Hide_From_Customer']['#text'].downcase == 'true'

        # Durations
        clean_ticket.initial_resolution_target_duration = ticket['Initial_Resolution_Target_Duration']['#text'].to_i
        clean_ticket.initial_response_target_duration   = ticket['Initial_Response_Target_Duration']['#text'].to_i

        # Ticket Number
        if ticket['Ticket_Number']
          clean_ticket.ticket_number = ticket['Ticket_Number']['#text']
        end

        # Queue
        if ticket['Ticket_Queue'] and ticket['Ticket_Queue']['Queue']
          clean_ticket.ticket_queue = OpenStruct.new
          clean_ticket.ticket_queue.id   = ticket['Ticket_Queue']['Queue']['@id']
          clean_ticket.ticket_queue.uid  = ticket['Ticket_Queue']['Queue']['@uid']
          clean_ticket.ticket_queue.href = ticket['Ticket_Queue']['Queue']['@href']
          clean_ticket.ticket_queue.name = ticket['Ticket_Queue']['Queue']["Name"]['#text']
        end

        # SLA
        if ticket['Ticket_Sla'] and ticket['Ticket_Sla']['Sla']
          clean_ticket.ticket_sla = OpenStruct.new
          clean_ticket.ticket_sla.id   = ticket['Ticket_Sla']['Sla']['@id']
          clean_ticket.ticket_sla.uid  = ticket['Ticket_Sla']['Sla']['@uid']
          clean_ticket.ticket_sla.href = ticket['Ticket_Sla']['Sla']['@href']
          clean_ticket.ticket_sla.name = ticket['Ticket_Sla']['Sla']["Name"]['#text']
        end

        # Status
        if ticket['Ticket_Status'] and ticket['Ticket_Status']['Status']
          clean_ticket.ticket_status = OpenStruct.new
          clean_ticket.ticket_status.id   = ticket['Ticket_Status']['Status']['@id']
          clean_ticket.ticket_status.uid  = ticket['Ticket_Status']['Status']['@uid']
          clean_ticket.ticket_status.href = ticket['Ticket_Status']['Status']['@href']
          clean_ticket.ticket_status.name = ticket['Ticket_Status']['Status']["Name"]['#text']
        end

        # Department
        if ticket['Department'] and ticket['Department']['Department']
          clean_ticket.department =  OpenStruct.new
          clean_ticket.department.id   = ticket['Department']['Department']["@id"]
          clean_ticket.department.uid  = ticket['Department']['Department']["@uid"]
          clean_ticket.department.href = ticket['Department']['Department']["@href"]
          clean_ticket.department.name = ticket['Department']['Department']["Name"]['#text']
        end

        # Customer Service Represenative
        if ticket['Entered_By'] and ticket['Entered_By']['Csr']
          clean_ticket.entered_by = OpenStruct.new
          clean_ticket.entered_by.id        = ticket['Entered_By']['Csr']['@id']
          clean_ticket.entered_by.uid       = ticket['Entered_By']['Csr']['@uid']
          clean_ticket.entered_by.href      = ticket['Entered_By']['Csr']['@href']
          clean_ticket.entered_by.full_name = ticket['Entered_By']['Csr']["Full_Name"]['#text']
        end

        # Customer
        if ticket['Ticket_Customer'] and ticket['Ticket_Customer']['Customer']
          clean_ticket.ticket_customer = OpenStruct.new
          clean_ticket.ticket_customer.id        = ticket['Ticket_Customer']['Customer']['@id']
          clean_ticket.ticket_customer.uid       = ticket['Ticket_Customer']['Customer']['@uid']
          clean_ticket.ticket_customer.href      = ticket['Ticket_Customer']['Customer']['@href']
          clean_ticket.ticket_customer.full_name = ticket['Ticket_Customer']['Customer']["Full_Name"]['#text']
        end

        # Attachements
        if ticket['Ticket_Attachments']
          clean_ticket.ticket_attachments = OpenStruct.new
          clean_ticket.ticket_attachments.id          = ticket['Ticket_Attachments']['@id']
          clean_ticket.ticket_attachments.uid         = ticket['Ticket_Attachments']['@uid']
          clean_ticket.ticket_attachments.href        = ticket['Ticket_Attachments']['@href']
          clean_ticket.ticket_attachments.attachments = ticket['Ticket_Attachments']['Attachments']
        end

        clean_ticket
      end

    end
  end
end
