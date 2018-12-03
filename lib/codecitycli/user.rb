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
    end

    def authenticate
      @token = AuthToken.new(Request.post(auth_path, { email: @email, password: @password }))
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

  module CLI
    class User < Thor
      desc 'login EMAIL PASSWORD', 'log into code city with EMAIL and PASSWORD'
      option :as, type: :string, required: true
      def login(email, password)
        user = CodeCityCLI::User.new(email: email, password: password, user_type: options[:as].to_sym)

        user.account.authenticate
        token = user.account.token

        Config.instance.token = token
        Config.instance.user_id = user.account.id
        Config.instance.user_type = user.user_type
        Config.instance.save
      end

      desc 'new EMAIL PASSWORD', 'creates a new user with EMAIL and PASSWORD and signs it in'
      option :user_type, type: :string, default: 'student'
      option :first_name, type: :string, required: true
      option :last_name, type: :string, required: true
      def new(email, password)
        user = CodeCityCLI::User.new(user_type: options[:user_type], first_name: options[:first_name], last_name: options[:last_name], email: email, password: password)

        token = user.create

        Config.instance.api_key = token
        Config.instance.user_id = user.id
        Config.instance.save
      end

      desc 'update', 'updates the current user'
      option :email, type: :string
      option :password, type: :string
      option :user_type, type: :string
      option :first_name, type: :string
      option :last_name, type: :string
      def update
        user = CodeCityCLI::User.current_user

        user.email = options[:email] if options[:email]
        user.password = options[:password] if options[:password]
        user.user_type = options[:user_type] if options[:user_type]
        user.first_name = options[:first_name] if options[:first_name]
        user.last_name = options[:last_name] if options[:last_name]

        user.update
      end

      desc 'delete', 'deletes the current user'
      def delete
        user = CodeCityCLI::User.current_user

        user.delete

        Config.instance.api_key = nil
      end
    end
  end
end
