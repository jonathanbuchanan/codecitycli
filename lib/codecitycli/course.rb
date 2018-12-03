require 'thor'
require 'codecitycli/lesson'
require 'codecitycli/exercise'

module CodeCityCLI
  class Course
    attr_accessor :id
    attr_accessor :title
    attr_accessor :description
    attr_accessor :image_url
    attr_accessor :developer_id
    attr_accessor :organization_id

    def initialize(args)
      self.id = args[:id] if args[:id]
      self.title = args[:title] if args[:title]
      self.description = args[:description] if args[:description]
      self.image_url = args[:image_url] if args[:image_url]
      self.developer_id = args[:developer_id] if args[:developer_id]
      self.organization_id = args[:organization_id] if args[:organization_id]
    end

    def create(user)
      # POST /courses?title=a
      Request.post("/courses/", { course: get_params })
    end

    def update(user)
      # PUT /courses/course_id?repo_link=a&title=b
      Request.put("/courses/#{self.id}", { course: get_params })
    end

    def delete(user)
      # DELETE /courses/course_id
      Request.delete("/courses/#{self.id}", {})
    end

    def self.get(id)
      # GET /courses/#{id}
      raw_course = Request.get("/courses/#{id}", {})[:body]
      return Course.new(raw_course)
    end

    def self.index
      # GET /courses/
      raw_courses = Request.get("/courses/", {})[:body]
      return raw_courses.map { |c| Course.new(c) }
    end

    private

    def get_params
      params = {}
      params[:title] = self.title if self.title
      params[:description] = self.description if self.description
      params[:image_url] = self.image_url if self.image_url
      params[:developer_id] = self.developer_id if self.developer_id
      params[:organization_id] = self.organization_id if self.organization_id
      params
    end
  end

  module CLI
    class Course < Thor
      desc 'new TITLE', 'creates a course with TITLE'
      def new(title)
        print("Enter a description for the course: ")
        desc = STDIN.gets

        course = CodeCityCLI::Course.new(title: title, description: desc, image_url: "", developer_id: 1, organization_id: 1)
        
        course.create CodeCityCLI::User.current_user
      end

      desc 'update COURSE_ID', 'updates the course with id COURSE_ID'
      option :title, type: :string
      option :description, type: :string
      option :image_url, type: :string
      def update(course_id)
        course = CodeCityCLI::Course.new(id: course_id)

        course.title = options[:title] if options[:title]
        course.description = options[:description] if options[:description]
        course.image_url = options[:image_url] if options[:image_url]

        course.update CodeCityCLI::User.current_user
      end

      desc 'delete COURSE_ID', 'deletes the course with id COURSE_ID'
      def delete(course_id)
        course = CodeCityCLI::Course.new(id: course_id)

        course.delete CodeCityCLI::User.current_user
      end

      desc 'list', 'lists courses'
      option :level, type: :string, default: 'course'
      option :course_id, type: :numeric
      option :lesson_id, type: :numeric
      def list
        case options[:level]
        when 'course'
          list_courses
        when 'lesson'
          list_lessons(options[:course_id])
        when 'exercise'
          list_exercises(options[:course_id], options[:lesson_id])
        else
          # Error!
          puts('level must be course, lesson, or exercise')
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

      desc 'submit FILE', 'submits FILE as a solution to the exercise'
      option :exercise_id, type: :numeric, required: true
      def submit(file)
        exercise = CodeCityCLI::Exercise.new(id: options[:exercise_id])

        # exercise.submit
      end

      desc 'fetch EXERCISE_ID', 'fetches the exercise with EXERCISE_ID'
      def fetch(exercise_id)
        exercise = CodeCityCLI::Exercise.new(id: options[:exercise_id])

        # exercise.get
      end

      private
      def list_courses
        courses = CodeCityCLI::Course.index
        courses.each do |course|
          print("Course | ID: #{course.id}, Title: #{course.title}\n")
        end

      end

      def list_lessons(course_id)
        lessons = CodeCityCLI::Lesson.index(course_id)
        lessons.each do |lesson|
          print("Lesson | ID: #{lesson.id}, Title: #{lesson.title}\n")
        end
      end

      def list_exercises(course_id, lesson_id)
        exercises = CodeCityCLI::Exercise.index(course_id, lesson_id)
        exercises.each do |exercises|
          print("Exercise | ID: #{exercise.id}, Title: #{exercise.title}\n")
        end
      end
    end
  end
end
