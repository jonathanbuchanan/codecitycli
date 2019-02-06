require 'thor'
require 'codecitycli/request'

module CodeCityCLI
  class AuthToken
    attr_accessor :access_token
    attr_accessor :client
    attr_accessor :expiry
    attr_accessor :uid

    def initialize(args)
      self.access_token = args['access-token']
      self.client = args[:client]
      self.expiry = args[:expiry]
      self.uid = args[:uid]
    end

    def headers
      {
        "access-token" => @access_token,
        "client" => @client,
        "expiry" => @expiry,
        "uid" => @uid
      }
    end
  end

  class User
    attr_accessor :user_type
    attr_accessor :account

    def initialize(args = {})
      @user_type = args[:user_type]
      case @user_type
      when :student
        @account = Student.new(args)
      when :instructor
        @account = Instructor.new(args)
      when :developer
        @account = Developer.new(args)
      when :admin
        @account = Admin.new(args)
      else
        raise ValidationError, "account type must be student, instructor, developer, or admin"
      end
    end

    def self.current_user(load_full = false)
      user = User.new(user_type: Config.instance.user_type, id: Config.instance.user_id, token: Config.instance.token)

      if load_full
        # Load the full user from the API
      end

      return user
    end
  end

  class Account
    attr_accessor :id
    attr_accessor :organization_id
    attr_accessor :email
    attr_accessor :password
    attr_accessor :token

    def initialize(args = {})
      @id = args[:id] if args[:id]
      @organization_id = args[:organization_id] if args[:organization_id]
      @email = args[:email] if args[:email]
      @password = args[:password] if args[:password]
      @token = args[:token] if args[:token]
    end

    def authenticate
      validate
      response = Request.send(auth_endpoint, @email, @password)
      unless response[:body]
        raise APIError, "response does not have a body"
      end
      unless response[:body].key?(:success)
        raise APIError, "body does not have a success flag"
      end
      unless response[:body][:success] == true
        raise AuthenticationError, 'invalid login credentials'
      end
      unless response[:headers]
        raise APIError, "response does not have a header"
      end
      unless response[:headers]['access-token']
        raise APIError, "response does not have an access token"
      end
      unless response[:headers][:client]
        raise APIError, "response does not have a client"
      end
      unless response[:headers][:expiry]
        raise APIError, "response does not have an expiry"
      end
      unless response[:headers][:uid]
        raise APIError, "response does not have a uid"
      end
      @token = AuthToken.new(response[:headers])
    end

    private

    def validate
      unless defined? @email
        raise ValidationError, "email required for authentication"
      end
      unless defined? @password
        raise ValidationError, "password required for authentication"
      end
    end
  end

  class Student < Account
    def auth_endpoint
      :student_sign_in
    end
  end

  class Instructor < Account
    def auth_endpoint
      :instructor_sign_in
    end
  end

  class Developer < Account
    def auth_endpoint
      :developer_sign_in
    end
  end

  class Admin < Account
    def auth_endpoint
      :admin_sign_in
    end
  end
end
