require 'gyoku'
require 'nori'

module HotDogPrincess
  class Client
    module Slas

      @slas = nil
      @slas_raw = nil

      def fetch_slas(page_size = 100)
        @slas_raw = get "Sla", _pageSize_: page_size
        @slas_raw
      end

      def slas(page_size = 100, force_update = false)
        return @slas  if @slas and !force_update
        fetch_slas(page_size)
        return nil  unless @slas_raw
        @slas ||= []
        @slas_raw["Entities"]["Sla"].each do |sla|
          @slas.push parse_sla sla
        end
        @slas
      end

      def slas_raw
        @slas_raw
      end

      def sla_count
        return @slas.length  if @slas
        return @slas["Entities"].length  if @slas_raw
        0
      end

      def sla(sla_id, history = false)
        sla = get "Sla/#{sla_id}", _history_: history
        parse_sla sla['Sla']
      end

      def parse_sla(sla)
        # Meta
        clean_sla = {}
        clean_sla[:id]   = sla['@id'].to_i
        clean_sla[:uid]  = sla['@uid']
        clean_sla[:href] = sla['@href']
        clean_sla[:name] = sla['Name']['#text']

        clean_sla
      end

    end
  end
end
