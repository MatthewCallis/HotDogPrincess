require "restclient"
require "hotdogprincess/version"
require "hotdogprincess/client"
require "hotdogprincess/client/customers"
require "hotdogprincess/client/tickets"

module HotDogPrincess

  class Client

    include HotDogPrincess::Client::Customers
    include HotDogPrincess::Client::Tickets

    def initialize(options = {})
      @host = options[:host]
      @token = options[:token]
      @username = options[:username]
      @password = options[:password]
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
      pp url
      pp body
      pp options
      @last_response = RestClient.post url, body, options
      pp @last_response
      clean_response @last_response
    end

    def put(path, body, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}?_token_=#{@token}"
      options = {
        content_type: :xml
      }.merge(options)
      @last_response = RestClient.put url, body, options
      clean_response @last_response
    end

    def delete(path, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}"
      options = {
        _output_: @output_format,
        _token_: @token
      }.merge(options)
      @last_response = RestClient.delete url, { params: options }
      clean_response @last_response
    end

    def head(path, options = {})
      url = "https://#{@host}/api/v1/#{@account_id}/#{@department_id}/#{path.to_s}"
      options = {
        _output_: @output_format,
        _token_: @token
      }.merge(options)
      @last_response = RestClient.head url, { params: options }
      clean_response @last_response
    end

    def last_response
      @last_response if defined? @last_response
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

    def clean_response(response)
      if response[0..3] == "\xEF\xBB\xBF"
        response_hash = JSON.parse response[3..-1]
      else
        response_hash = JSON.parse response[3..-1]
      end
      response_hash
    end

    def schema(object)
      get "#{object.to_s}/schema"
    end

  end
end
