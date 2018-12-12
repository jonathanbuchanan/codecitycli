module CodeCityCLI
  class ConnectionError < StandardError
    def initialize(msg)
      super
    end
  end

  class ParseError < StandardError
    def initialize(msg)
      super
    end
  end

  class APIError < StandardError
    def initialize(msg)
      super
    end
  end
end
