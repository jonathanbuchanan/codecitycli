require 'faraday'
require 'faraday_middleware'

module CodeCityCLI
  module Request
    @@request_prefix = 'http://localhost:3000/api/v1'

    def self.get(ext, params, headers={})
      make_connection(@@request_prefix + ext) { |c| c.get '', params, headers }
    end

    def self.post(ext, params, headers={})
      make_connection(@@request_prefix + ext) { |c| c.post '', params, headers }
    end

    def self.put(ext, params, headers={})
      make_connection(@@request_prefix + ext) { |c| c.put '', params, headers }
    end

    def self.delete(ext, params, headers={})
      make_connection(@@request_prefix + ext) { |c| c.delete '', params, headers }
    end

    private

    def self.make_connection(url)
      connection = Faraday.new(url: url) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
        faraday.adapter Faraday.default_adapter
        faraday.options.timeout = 15
        faraday.options.open_timeout = 5
      end
      result = {}
      begin
        result = yield(connection)
      rescue Faraday::TimeoutError => e
        raise ConnectionError, 'connection timed out'
      rescue Faraday::ClientError => e
        raise ConnectionError
      end
      if result.status != 200
        raise APIError, result.body[:message]
      end
      { body: result.body, headers: result.headers }
    end
  end
end
