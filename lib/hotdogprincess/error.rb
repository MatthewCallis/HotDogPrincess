module HotDogPrincess
  class Error < StandardError
    attr_accessor :object
    def initialize(message = nil, object = nil)
      super(message)
      self.object = object
    end
  end
end
