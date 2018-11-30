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
    attr_accessor :id
    attr_accessor :user_type
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :email
    attr_accessor :password

    def initialize(args = {})
      self.id = args[:id] if args[:id]
      self.user_type = args[:user_type] if args[:user_type]
      self.first_name = args[:first_name] if args[:first_name]
      self.last_name = args[:last_name] if args[:last_name]
      self.email = args[:email] if args[:email]
      self.password = args[:password] if args[:password]
    end

    def self.current_user(load_full = false)
      user = User.new(id: Config.instance.user_id)

      if load_full
        user_data = Request.get("/students/#{user.id}")
        # Load the full user from the API
      end

      return user
    end

    def authenticate
      # POST /authenticate?email=email&password=password
      # return token
      token = AuthToken.new(Request.post("/students/sign_in", { email: self.email, password: self.password }))
    end

    def create
      # POST /users?user_type=user_type&first_name=first_name&last_name=last_name&email=email&password=password
      # return token
    end

    def update
      # PUT /users/id&user_type=user_type&first_name=first_name&last_name=last_name&email=email&password=password
    end

    def delete
      # DELETE /users/self.id
    end
  end

  module CLI
    class User < Thor
      desc 'login EMAIL PASSWORD', 'log into code city with EMAIL and PASSWORD'
      def login(email, password)
        user = CodeCityCLI::User.new

        user.email = email
        user.password = password

        token = user.authenticate

        Config.instance.token = token
        Config.instance.user_id = user.id
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
