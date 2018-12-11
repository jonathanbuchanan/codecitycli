require 'codecitycli/version'
require 'codecitycli/config'
require 'codecitycli/course'
require 'codecitycli/user'
require 'thor'

module CodeCityCLI
  module CLI
    class Main < Thor
      desc 'config', 'configure settings for the client'
      option :user_id, type: :numeric
      option :api_key, type: :string
      option :directory, type: :string
      def config
        Config.instance.user_id = options[:user_id] if options[:user_id]
        Config.instance.api_key = options[:api_key] if options[:api_key]
        Config.instance.directory = options[:directory] if options[:directory]

        Config.instance.save
      end

      desc 'user SUBCOMMAND', 'manage users'
      subcommand 'user', CLI::User

      desc 'course SUBCOMMAND', 'manage courses'
      subcommand 'course', CLI::Course

      desc 'token EMAIL USER_TYPE', 'create a token for the user of type USER_TYPE and email EMAIL'
      def token(email, user_type)
        user = CodeCityCLI::User.current_user
        response = Request.get("/tokens/generate", { organization_id: user.account.organization_id, email: email, user_type: user_type }, user.account.token.headers)
        token = response[:body][:token]
        print(token)
        print("\n")
      end
    end
  end
end
