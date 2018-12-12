require 'codecitycli/version'
require 'codecitycli/config'
require 'codecitycli/course'
require 'codecitycli/user'
require 'codecitycli/exceptions'
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
      rescue CodeCityCLIError => e
        show_error e
      end

      desc 'login EMAIL PASSWORD', 'login in with EMAIL and PASSWORD'
      option :as, type: :string, required: true
      def login(email, password)
        user = CodeCityCLI::User.new(email: email, password: password, user_type: options[:as].to_sym)                                                                                                 
   
        user.account.authenticate
        token = user.account.token

        Config.instance.token = token
        Config.instance.user_id = user.account.id
        Config.instance.user_type = user.user_type
        Config.instance.save
      rescue CodeCityCLIError => e
        show_error e
      end

      desc 'logout', 'logs out the current user'
      def logout
        Config.instance.token = nil
        Config.instance.user_id = nil
        Config.instance.user_type = nil
        Config.instance.save
      rescue CodeCityCLIError => e
        show_error e
      end

      desc 'course SUBCOMMAND', 'manage courses'
      subcommand 'course', CLI::Course

      desc 'token EMAIL USER_TYPE', 'create a token for the user of type USER_TYPE and email EMAIL'
      def token(email, user_type)
        user = CodeCityCLI::User.current_user
        response = Request.get("/tokens/generate", { organization_id: user.account.organization_id, email: email, user_type: user_type }, user.account.token.headers)
        token = response[:body][:token]
        print(token)
        print("\n")
      rescue CodeCityCLIError => e
        show_error e
      end

      desc 'fetch COURSE_ID/LESSON_ID/EXERCISE_ID', 'fetches the exercise with COURSE_ID, LESSON_ID, and EXERCISE_ID'
      def fetch(exercise_path)
        path = parse_exercise_path exercise_path
        exercise = CodeCityCLI::Exercise.new(id: path[:exercise], lesson_id: path[:lesson], course_id: path[:course])
        exercise.show CodeCityCLI::User.current_user
      rescue CodeCityCLIError => e
        show_error e
      end

      desc 'test COURSE_ID/LESSON_ID/EXERCISE_ID FILENAME', 'tests the exercise solution at FILENAME with COURSE_ID, LESSON_ID, and EXERCISE_ID'
      def test(exercise_path, filename)
        path = parse_exercise_path exercise_path
      rescue CodeCityCLIError => e
        show_error e
      end

      desc 'push COURSE_ID/LESSON_ID/EXERCISE_ID FILENAME', 'pushes the exercise solution at FILENAME with COURSE_ID, LESSON_ID, and EXERCISE_ID'
      def push(exercise_path, filename)
        path = parse_exercise_path exercise_path
        exercise = CodeCityCLI::Exercise.new(id: path[:exercise], lesson_id: path[:lesson], course_id: path[:course])
        print(exercise.push(filename, CodeCityCLI::User.current_user))
        print("\n")
      rescue CodeCityCLIError => e
        show_error e
      end

      private

      def parse_exercise_path(path)
        pieces = path.split('/')
        if pieces.count != 3
          raise ParseError, 'malformed path to exercise'
        end
        { course: pieces[0], lesson: pieces[1], exercise: pieces[2] }
      end

      def show_error(e)
        title = 'Error'
        case e
        when ConnectionError
          title = 'Connection Error'
        when ParseError
          title = 'Parsing Error'
        when APIError
          title = 'API Error'
        when AuthenticationError
          title = 'Authentication Error'
        end
        if e.message.empty?
          print("#{title}\n")
        else
          print("#{title}: #{e.message}\n")
        end
      end
    end
  end
end
