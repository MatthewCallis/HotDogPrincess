require "restclient"
require "hotdogprincess/version"
require "hotdogprincess/client/customers"
require "hotdogprincess/client/tickets"
require "hotdogprincess/client/slas"

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
      @last_response = RestClient.get url, { params: options }
      clean_response @last_response
    end

    def post(path, body, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}?_token_=#{@token}"
      options = {
        content_type: :xml
      }.merge(options)
      @last_response = RestClient.post url, body, options
      @last_response
    end

    def put(path, body, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}?_token_=#{@token}&_enforceRequiredFields_=false"
      options = {
        content_type: :xml
      }.merge(options)
      @last_response = RestClient.put url, body, options
      @last_response
    end

    def delete(path, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}"
      options = {
        _output_: @output_format,
        _token_: @token
      }.merge(options)
      @last_response = RestClient.delete url, { params: options }
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
      # "\xEF", "\xBB", "\xBF"
      if response[0].ord == 239 and response[1].ord == 187 and response[2].ord == 191
        response_hash = JSON.parse response[3..-1]
      else
        response_hash = JSON.parse response
      end
      response_hash
    end

    def schema(object)
      get "#{object.to_s}/schema"
    end

    def schema_json(object)
      schema = schema(object)
      schema_hash = schema_parse_hash(schema[object])

      JSON.generate(schema_hash)
    end

    def schema_parse_array(input_array)
      output = []
      input_array.each do |item|
        if item.class == Array
          output.push  schema_parse_array(item)
        elsif item.class == Hash
          output.push  schema_parse_hash(item)
        elsif value.class == String
          output.push schema_parse_string(item)
        else
          output.push  item
        end
      end
      output
    end

    def schema_parse_hash(input_hash)
      output = {}
      input_hash.each do |key, value|
        if value.class == Array
          output[key.to_s.name_to_key] = schema_parse_array(value)
        elsif value.class == Hash
          output[key.to_s.name_to_key] = schema_parse_hash(value)
        elsif value.class == String
          output[key.to_s.name_to_key] = schema_parse_string(value)
        else
          output[key.to_s.name_to_key] = value
        end
      end
      output
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
