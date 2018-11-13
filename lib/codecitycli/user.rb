require 'thor'

module CodeCityCLI
  class User
    attr_accessor :id
    attr_accessor :user_type
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :email
    attr_accessor :password

    def authenticate
      # /authenticate?email=email&password=password
      # return token
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

        Config.instance.api_key = token
        Config.instance.save
      end
    end
  end
end
