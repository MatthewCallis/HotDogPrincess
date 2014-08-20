
module HotDogPrincess
  class CoreExtensions
    module String
      def name_to_key
        self.gsub(/[^a-z _-]/i, '')
            .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
            .gsub(/([a-z\d])([A-Z])/,'\1_\2')
            .tr(' ', '_')
            .tr('-', '_')
            .downcase
      end
    end
  end
end

class String
  include HotDogPrincess::CoreExtensions::String
end
