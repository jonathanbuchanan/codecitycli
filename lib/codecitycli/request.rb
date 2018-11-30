require 'faraday'

module CodeCityCLI
  module Request
    @@request_prefix = 'http://localhost:3000/api/v1'

    def self.get(ext, params={})
      connection = Faraday.get(url: @@request_prefix + ext)
      response = connection.get '', params
      { body: response.body, headers: response.headers }
    end

    def self.post(ext, params={})
      connection = Faraday.new(url: @@request_prefix + ext)
      response = connection.post '', params
      { body: response.body, headers: response.headers }
    end

    def self.put(ext, params={})
      connection = Faraday.new(url: @@request_prefix + ext)
      response = connection.put '', params
      { body: response.body, headers: response.headers }
    end

    def self.delete(ext, params={})
      connection = Faraday.new(url: @@request_prefix + ext)
      response = connection.delete '', params
      { body: response.body, headers: response.headers }
    end
  end
end
