module CodeCityCLI
  class Exercise
    attr_accessor :test_path
    attr_accessor :test_name
    attr_accessor :exercise_path
    attr_accessor :exercise_name

    def initialize(args)
      self.test_path = args[:test_path] if args[:test_path]
      self.test_name = args[:test_name] if args[:test_name]
      self.exercise_path = args[:exercise_path] if args[:exercise_path]
      self.exercise_name = args[:exercise_name] if args[:exercise_name]
    end

    def push(submission_path, user)
      #submission = get_local_file(submission_path)
      submission = ""

      response = Request.post("/courses/#{self.course_id}/lessons/#{self.lesson_id}/exercises/push", { id: self.id, submission: submission }, user.account.token.headers)
      response[:body]
    end

    def test(submission_path)
      # Run the test
    end

    def self.fetch(course_id, lesson_id, exercise_id, user)
      response = Request.get("/courses/#{course_id}/lessons/#{lesson_id}/exercises/#{exercise_id}", {}, user.account.token.headers)

      unless response != nil
        raise APIError, "got no response"
      end
      unless response[:body]
        raise APIError, "response has no body"
      end
      unless response[:body][:test_path]
        raise APIError, "response has no test path"
      end
      unless response[:body][:test_name]
        raise APIError, "response has no test name"
      end
      unless response[:body][:exercise_path]
        raise APIError, "response has no exercise path"
      end
      unless response[:body][:exercise_name]
        raise APIError, "response has no exercise name"
      end

      return self.new(test_path: response[:body][:test_path],
        test_name: response[:body][:test_name],
        exercise_path: response[:body][:exercise_path],
        exercise_name: response[:body][:exercise_name])

      #test_file = get_file(response[:body][:test_path])
      #exercise_file = get_file(response[:body][:exercise_path])

      #test_path = Config.instance.directory + '/' + course_name + '/' + lesson_name + '/' + response[:body][:test_name]
      #exercise_path = Config.instance.directory + '/' + course_name + '/' + lesson_name + '/' + response[:body][:exercise_name]

      #save_file(test_path, test_file)
      #save_file(exercise_path, exercise_file)
    end

    private

    def get_file(url)
      Faraday.get(url).body
    end

    def get_local_file(path)
      content = ''

      f = File.open(path, 'r')
      f.each_line do |line|
        content += line
      end

      content
    end

    def save_file(path, content)
      setup_directories(File.dirname(path))
      f = File.open(path, 'w')
      f.write(content)
    end

    def setup_directories(path)
      if !File.directory?(path)
        FileUtils.mkdir_p(path)
      end
    end

    def course_name
      course = Course.get(@course_id, User.current_user)
      course.title
    end

    def lesson_name
      lesson = Lesson.get(@course_id, @lesson_id, User.current_user)
      lesson.title
    end
  end
end
