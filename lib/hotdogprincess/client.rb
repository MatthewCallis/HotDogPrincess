require "restclient"
require "hotdogprincess/version"
require "hotdogprincess/client/customers"
require "hotdogprincess/client/tickets"
require "hotdogprincess/client/slas"
require 'hotdogprincess/error'

module HotDogPrincess

  class Client

    include HotDogPrincess::Client::Customers
    include HotDogPrincess::Client::Tickets
    include HotDogPrincess::Client::Slas

    def initialize(options = {})
      @host = options[:host]
      @token = options[:token]
      @account_id = options[:account_id]
      @department_id = options[:department_id]
      @output_format = :json
    end

    def get(path, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}"
      options = {
        _output_: @output_format,
        _token_: @token
      }.merge(options)
      begin
        @last_response = RestClient.get url, { params: options }
      rescue => e
        raise HotDogPrincess::Error.new(e.response, self)
      end
      clean_response @last_response
    end

    def post(path, body, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}?_token_=#{@token}"
      options = {
        content_type: :xml
      }.merge(options)
      begin
        @last_response = RestClient.post url, body, options
      rescue => e
        raise HotDogPrincess::Error.new(e.response, self)
      end
      @last_response
    end

    def put(path, body, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}?_token_=#{@token}&_enforceRequiredFields_=false"
      options = {
        content_type: :xml
      }.merge(options)
      begin
        @last_response = RestClient.put url, body, options
      rescue => e
        raise HotDogPrincess::Error.new(e.response, self)
      end
      @last_response
    end

    def delete(path, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}"
      options = {
        _output_: @output_format,
        _token_: @token
      }.merge(options)
      begin
        @last_response = RestClient.delete url, { params: options }
      rescue => e
        raise HotDogPrincess::Error.new(e.response, self)
      end
      @last_response
    end

    def host=(value)
      @host = value
    end

    def host
      @host
    end

    def token=(value)
      @token = value
    end

    def token
      @token
    end

    def account_id=(value)
      @account_id = value
    end

    def account_id
      @account_id
    end

    def department_id=(value)
      @department_id = value
    end

    def department_id
      @department_id
    end

    def last_response
      @last_response if defined? @last_response
    end

    def clean_response(response)
      return nil  unless response and response.class == String
      return nil  unless response.length >= 3
      begin
        # "\xEF", "\xBB", "\xBF"
        if response[0].ord == 239 and response[1].ord == 187 and response[2].ord == 191
          response_hash = JSON.parse response[3..-1]
        else
          response_hash = JSON.parse response
        end
      rescue
        response_hash = nil
      end
      response_hash
    end

    def status_raw(object)
      get "#{object.to_s}/status"
    end

    def status(object)
      status = status_raw(object)
      if status['Entities'] and status['Entities']['Status']
        status_hash = schema_parse(status['Entities']['Status'])
      elsif status['entities'] and status['entities']['Status']
        # With _output_=json the container is lowercase for some reason.
        status_hash = schema_parse(status['entities']['Status'])
      end
      status_hash
    end

    def status_json(object)
      status = status_raw(object)
      if status['Entities'] and status['Entities']['Status']
        status_hash = schema_parse(status['Entities']['Status'])
      elsif status['entities'] and status['entities']['Status']
        # With _output_=json the container is lowercase for some reason.
        status_hash = schema_parse(status['entities']['Status'])
      end
      JSON.generate(status_hash)
    end

    def view_raw(object)
      get "#{object.to_s}/view"
    end

    def view(object)
      views = view_raw(object)
      views_hash = schema_parse(views['Entities']['View'])
      views_hash
    end

    def view_json(object)
      views = view_raw(object)
      views_hash = schema_parse(views['Entities']['View'])
      JSON.generate(views_hash)
    end

    def schema_raw(object)
      get "#{object.to_s}/schema"
    end

    def schema(object)
      schema = schema_raw(object)
      schema_hash = schema_parse(schema[object])
      schema_hash
    end

    def schema_json(object)
      schema = schema_raw(object)
      schema_hash = schema_parse(schema[object])
      JSON.generate(schema_hash)
    end

    def schema_parse(input)
      if input.is_a? String
        schema_parse_string(input)
      elsif input.is_a? Array
        input.map { |item| schema_parse(item) }
      elsif input.is_a? Hash
        input.inject({}) do |memo, (key, value)|
          memo[key.to_s.name_to_key] = schema_parse(value)
          memo
        end
      else
        input
      end
    end

    def schema_parse_string(input_string)
      case input_string
      when 'true'
        true
      when 'false'
        false
      else
        # Check for Integers / Floats
        if /^-?(?:[0-9]+|[0-9]*\.[0-9]+)$/ =~ input_string
          if input_string.to_i == input_string.to_f
            input_string.to_i
          else
            input_string.to_f
          end
        else
          input_string
        end
      end
    end

  end
end
