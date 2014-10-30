module HotDogPrincess
  class CoreExtensions
    module Hash

      def compact
        # inject({}) do |new_hash, (k, v)|
        #   if !v.nil?
        #     new_hash[k] = v.class == Hash ? v.compact : v
        #   end
        #   new_hash
        # end
        delete_if { |k, v|
          (v.is_a?(Hash) and v.respond_to?('empty?') and v.compact.empty?) or (v.nil?)
        }
      end

    end
  end
end

class Hash
  include HotDogPrincess::CoreExtensions::Hash
end
