require 'gyoku'

module HotDogPrincess
  class Client
    module Customers

      def customers(page_size = 100)
        customers = get "Customer", _pageSize_: page_size
        customers["Entities"]
      end

      def customers_since(start_date, page_size = 100)
        customers = get "Customer", _pageSize_: page_size, Date_Created: start_date
        customers["Entities"]
      end

      def customer(customer_id, history = false)
        get "Customer/#{ticket_id}", _history_: history
      end

      def create_customer(*args)
        xml = Gyoku.xml(args[:customer])
        post "Customer", xml
      end

    end
  end
end
