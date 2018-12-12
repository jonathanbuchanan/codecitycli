require 'faraday'
require 'faraday_middleware'

module CodeCityCLI
  module Request
    @@request_prefix = 'http://localhost:3000/api/v1'

    def self.get(ext, params, headers={})
      connection = make_connection @@request_prefix + ext
      response = connection.get '', params, headers
      { body: response.body, headers: response.headers }
    end

    def self.post(ext, params, headers={})
      connection = make_connection @@request_prefix + ext
      response = connection.post '', params, headers
      { body: response.body, headers: response.headers }
    end

    def self.put(ext, params, headers={})
      connection = make_connection @@request_prefix + ext
      response = connection.put '', params, headers
      { body: response.body, headers: response.headers }
    end

    def self.delete(ext, params, headers={})
      connection = make_connection @@request_prefix + ext
      response = connection.delete '', params, headers
      { body: response.body, headers: response.headers }
    end

    private

    def self.make_connection(url)
      Faraday.new(url: url) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
