module CodeCityCLI
  class CodeCityCLIError < StandardError
    def initialize(msg = '')
      super
    end
  end

  class ConnectionError < CodeCityCLIError
    def initialize(msg = '')
      super
    end
  end

  class ParseError < CodeCityCLIError
    def initialize(msg = '')
      super
    end
  end

  class AuthenticationError < CodeCityCLIError
    def initialize(msg = '')
      super
    end
  end

  class APIError < CodeCityCLIError
    def initialize(msg = '')
      super
    end
  end
end
