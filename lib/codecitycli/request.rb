require 'faraday'
require 'faraday_middleware'

module CodeCityCLI
  module Request
    private

    def self.get_organization
      unless Config.instance.organization != nil
        raise ValidationError, "organization must be defined"
      end
      Config.instance.organization
    end

    def self.development_request_prefix
      "http://#{get_organization}.lvh.me:3000/api/v1"
    end

    def self.production_request_prefix
      "http://#{get_organization}.codecity.com/api/v1"
    end

    def self.request_prefix
      environment = :development
      if environment == :development
        return development_request_prefix
      elsif environment == :production
        return production_request_prefix
      end
    end

    public

    def self.student_sign_in(email, password)
      post("/students/sign_in", { email: email, password: password })
    end

    def self.instructor_sign_in(email, password)
      post("/instructors/sign_in", { email: email, password: password })
    end

    def self.developer_sign_in(email, password)
      post("/developers/sign_in", { email: email, password: password })
    end

    def self.admin_sign_in(email, password)
      post("/admins/sign_in", { email: email, password: password })
    end

    private

    def self.get(ext, params, headers={})
      make_connection(request_prefix + ext) { |c| c.get '', params, headers }
    end

    def self.post(ext, params, headers={})
      print(request_prefix + ext + "\n")
      make_connection(request_prefix + ext) { |c| c.post '', params, headers }
    end

    def self.put(ext, params, headers={})
      make_connection(request_prefix + ext) { |c| c.put '', params, headers }
    end

    def self.delete(ext, params, headers={})
      make_connection(request_prefix + ext) { |c| c.delete '', params, headers }
    end

    def self.make_connection(connection_url)
      connection = Faraday.new(:url => connection_url) do |faraday|
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
        if result.body.is_a? Hash and result.body.key? :message
          raise APIError, result.body[:message]
        else
          raise APIError
        end
      end
      { body: result.body, headers: result.headers }
    end
  end
end
