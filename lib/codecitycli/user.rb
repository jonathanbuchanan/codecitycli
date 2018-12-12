require 'thor'
require 'codecitycli/request'

module CodeCityCLI
  class AuthToken
    attr_accessor :access_token
    attr_accessor :client
    attr_accessor :expiry
    attr_accessor :uid

    def initialize(response)
      self.access_token = response[:headers]['access-token']
      self.client = response[:headers][:client]
      self.expiry = response[:headers][:expiry]
      self.uid = response[:headers][:uid]
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
      response = Request.post(auth_path, { email: @email, password: @password })
      if response[:body].key?(:success) and response[:body][:success] == false
        raise AuthenticationError, 'invalid login credentials'
      end
      @token = AuthToken.new(response)
    end
  end

  class Student < Account
    def auth_path
      '/students/sign_in'
    end
  end

  class Instructor < Account
    def auth_path
      '/instructors/sign_in'
    end
  end

  class Developer < Account
    def auth_path
      '/developers/sign_in'
    end
  end

  class Admin < Account
    def auth_path
      '/admins/sign_in'
    end
  end
end
