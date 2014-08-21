require 'gyoku'
require 'nori'

module HotDogPrincess
  class Client
    module Customers

      @customers = nil
      @customers_raw = nil

      def fetch_customers(page_size = 100)
        @customers_raw = get 'Customer', _pageSize_: page_size
        @customers_raw
      end

      def customers(page_size = 100, force_update = false)
        return @customers  if @customers and !force_update
        fetch_customers(page_size)
        return nil  unless @customers_raw
        @customers ||= []
        @customers_raw["Entities"]["Customer"].each do |customer|
          @customers.push parse_customer customer
        end
        @customers
      end

      def customers_raw(page_size = 100)
        return @customers_raw  if @customers_raw
        fetch_customers(page_size)
        @customers_raw
      end

      def customer_count
        return @customers.length  if @customers
        return @customers["Entities"].length  if @customers_raw
        0
      end

      def customer(customer_id, history = false)
        customer = get "Customer/#{customer_id}", _history_: history
        parse_customer customer['Customer']
      end

      def update_customer(customer_id, customer)
        xml = Gyoku.xml(customer)
        customer_xml = put "Customer/#{customer_id}", xml

        parser = Nori.new
        new_customer_xml = parser.parse customer_xml

        customer = get "Customer/#{new_customer_xml['Customer']['@id']}", _history_: false

        parse_customer customer['Customer']
      end

      def create_customer(customer)
        xml = Gyoku.xml(customer)
        customer_xml = post 'Customer', xml

        parser = Nori.new
        new_customer_xml = parser.parse customer_xml

        customer = get "Customer/#{new_customer_xml['Customer']['@id']}", _history_: false

        parse_customer customer['Customer']
      end

      def find_customer_by_email(email, substring = false)
        query = 'Email'
        query << '_like_'  if substring
        customers = get 'Customer', "#{query}" => email

        found_customers = []
        if customers and customers["Entities"] and customers["Entities"]["Customer"]
          customers["Entities"]["Customer"].each do |customer|
            found_customers.push parse_customer customer
          end
        end

        found_customers
      end

      def parse_customer(customer)
        # Meta
        clean_customer = {}
        clean_customer[:id]               = customer['@id'].to_i
        clean_customer[:uid]              = customer['@uid']
        clean_customer[:href]             = customer['@href']
        clean_customer[:service_desk_uri] = customer['@service-desk-uri']

        # Basic Info
        clean_customer[:first_name] = customer['First_Name']['#text']
        clean_customer[:last_name]  = customer['Last_Name']['#text']
        clean_customer[:email]      = customer['Email']['#text']

        # Dates
        clean_customer[:date_created] = Time.parse(customer['Date_Created']['#text']).utc.to_date  if customer['Date_Created']
        clean_customer[:date_updated] = Time.parse(customer['Date_Updated']['#text']).utc.to_date  if customer['Date_Updated']
        clean_customer[:date_visited] = Time.parse(customer['Date_Visited']['#text']).utc.to_date  if customer['Date_Visited']

        # Customer Role
        if customer['Customer_Role'] and customer['Customer_Role']['CustomerRole']
          clean_customer[:customer_role] = {}
          clean_customer[:customer_role][:id]   = customer['Customer_Role']['CustomerRole']['@id'].to_i
          clean_customer[:customer_role][:uid]  = customer['Customer_Role']['CustomerRole']['@uid']
          clean_customer[:customer_role][:href] = customer['Customer_Role']['CustomerRole']['@href']
          clean_customer[:customer_role][:name] = customer['Customer_Role']['CustomerRole']["Name"]['#text']
        end

        # SLA
        if customer['Sla'] and customer['Sla']['Sla']
          clean_customer[:sla] = {}
          clean_customer[:sla][:id]   = customer['Sla']['Sla']['@id'].to_i
          clean_customer[:sla][:uid]  = customer['Sla']['Sla']['@uid']
          clean_customer[:sla][:href] = customer['Sla']['Sla']['@href']
          clean_customer[:sla][:name] = customer['Sla']['Sla']["Name"]['#text']
        end

        # Status
        if customer['Status'] and customer['Status']['Status']
          clean_customer[:status] = {}
          clean_customer[:status][:id]   = customer['Status']['Status']['@id'].to_i
          clean_customer[:status][:uid]  = customer['Status']['Status']['@uid']
          clean_customer[:status][:href] = customer['Status']['Status']['@href']
          clean_customer[:status][:name] = customer['Status']['Status']["Name"]['#text']
        end

        # Custom Field
        if customer['Custom_Field']
          clean_customer[:custom_field] = {}

          # Multple are returned as an Array, single as a Hash.
          if customer['Custom_Field'].class != Array
            customer['Custom_Field'] = [customer['Custom_Field']]
          end

          customer['Custom_Field'].each do |custom_field|
            field = custom_field['@display-name'].name_to_key
            field_key = field.to_sym
            clean_customer[:custom_field][field_key] = {}
            clean_customer[:custom_field][field_key][:id]          = custom_field['@id'].to_i
            clean_customer[:custom_field][field_key][:required]    = custom_field['@required'].downcase == 'true'  if custom_field['@required']
            clean_customer[:custom_field][field_key][:editable]    = custom_field['@editable'].downcase == 'true'  if custom_field['@editable']
            clean_customer[:custom_field][field_key][:max_length]  = custom_field['@max-length'].to_i  if custom_field['@max-length']
            clean_customer[:custom_field][field_key][:field_type]  = custom_field['@field-type']  if custom_field['@field-type']
            clean_customer[:custom_field][field_key][:data_type]   = custom_field['@data-type']  if custom_field['@data-type']
            clean_customer[:custom_field][field_key][:multi_value] = custom_field['@multi-value'].downcase == 'true'  if custom_field['@multi-value']

            # Get the value or values.
            case custom_field['@data-type']
            when 'string'
              clean_customer[:custom_field][field_key][:value] = custom_field['#text']
            when 'int'
              clean_customer[:custom_field][field_key][:value] = custom_field['#text'].to_i
            when 'date'
              clean_customer[:custom_field][field_key][:value] = Time.parse(custom_field['#text']).utc.to_date
            when 'boolean'
              clean_customer[:custom_field][field_key][:value] = custom_field['#text'] == 'true'
            when 'float'
              clean_customer[:custom_field][field_key][:value] = custom_field['#text'].to_f
            when 'option'
              selected_options = []
              custom_field['Option'].each do |option|
                if option["@selected"] == 'true'
                  selected_option = {}
                  selected_option[:id]         = option["@id"].to_i
                  selected_option[:view_order] = option["@viewOrder"]
                  selected_option[:value]      = option["Value"]
                  selected_options.push selected_option
                end
              end
              selected_options = selected_options.first  unless clean_customer[:custom_field][field_key][:multi_value]
              clean_customer[:custom_field][field_key][:value] = selected_options
            when 'entity'
              clean_customer[:custom_field][field_key].value = nil
            when 'attachment'
              clean_customer[:custom_field][field_key].value = nil
            else
              clean_customer[:custom_field][field_key].value = nil
            end
          end
        end

        clean_customer
      end

    end
  end
end
