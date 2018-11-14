require 'thor'

module CodeCityCLI
  class Course
    attr_accessor :title
    attr_accessor :id
    attr_accessor :repo_link

    def initialize(args)
      self.title = args[:title] if args[:title]
      self.id = args[:id] if args[:id]
      self.repo_link = args[:repo_link] if args[:repo_link]
    end

    def create(user)
      # POST /courses?repo_link=a&title=b
    end

    def update(user)
      # PUT /courses/course_id?repo_link=a&title=b
    end

    def delete(user)
      # DELETE /courses/course_id
    end

    def self.index
      # GET /courses/
      # return courses
      return []
    end

    def enroll(user, course_token)
      # POST /courses/course_id/enroll?user_id=a&course_token=b
    end

    def disenroll(user)
      # POST /courses/course_id/disenroll?user_id=a
    end
  end

  module CLI
    class Course < Thor
      desc 'new TITLE', 'creates a course with TITLE'
      option :repo_link, type: :string, required: true
      def new(title)
        course = CodeCityCLI::Course.new(title: title, repo_link: options[:repo_link])

        course.create CodeCityCLI::User.current_user
      end

      desc 'update COURSE_ID', 'updates the course with id COURSE_ID'
      option :title, type: :string
      option :repo_link, type: :string
      def update(course_id)
        course = CodeCityCLI::Course.new(id: course_id)

        course.title = options[:title] if options[:title]
        course.repo_link = options[:repo_link] if options[:repo_link]

        course.update CodeCityCLI::User.current_user
      end

      desc 'delete COURSE_ID', 'deletes the course with id COURSE_ID'
      def delete(course_id)
        course = CodeCityCLI::Course.new(id: course_id)

        course.delete CodeCityCLI::User.current_user
      end

      desc 'list', 'lists courses'
      def list
        courses = CodeCityCLI::Course.index
        courses.each do |course|
          print("ID: #{course.id}, Title: #{course.title}\n")
        end
      end

      desc 'enroll COURSE_ID COURSE_TOKEN', 'enrolls the current user in the course with id COURSE_ID using COURSE_TOKEN'
      def enroll(course_id, course_token)
        course = CodeCityCLI::Course.new(id: course_id)

        course.enroll(CodeCityCLI::User.current_user, course_token)
      end

      desc 'disenroll COURSE_ID', 'disenrolls the current user from the course with id COURSE_ID'
      def disenroll(course_id)
        # Prompt user for confirmation
        print("Continue disenrolling? (y/n)\n")
        if STDIN.gets != "y\n"
          return
        end

        course = CodeCityCLI::Course.new(id: course_id)

        course.disenroll CodeCityCLI::User.current_user
      end
    end
  end
end
