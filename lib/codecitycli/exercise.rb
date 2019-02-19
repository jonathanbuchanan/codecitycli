require 'digest/sha1'

module CodeCityCLI
  class Exercise
    # Required
    attr_accessor :course_id
    attr_accessor :lesson_id
    attr_accessor :exercise_id

    # Details (optional)
    attr_accessor :title
    attr_accessor :instructions
    attr_accessor :test_url
    attr_accessor :exercise_url
    attr_accessor :point_value

    def initialize(args)
      self.course_id = args[:course_id]
      self.lesson_id = args[:lesson_id]
      self.exercise_id = args[:exercise_id]

      self.title = args[:title] if args[:title]
      self.instructions = args[:instructions] if args[:instructions]
      self.test_url = args[:test_url] if args[:test_url]
      self.exercise_url = args[:exercise_url] if args[:exercise_url]
      self.point_value = args[:point_value] if args[:point_value]
    end

    def hex_prefix
      Digest::SHA1.hexdigest(course_id.to_s.rjust(5, '0') + lesson_id.to_s.rjust(5, '0') + exercise_id.to_s.rjust(5, '0'))
    end

    def self.fetch(course_id, lesson_id, exercise_id, user)
      response = Request.get("/courses/#{course_id}/lessons/#{lesson_id}/exercises/#{exercise_id}", {}, user.account.token.headers)

      unless response != nil
        raise APIError, "got no response"
      end
      unless response[:body]
        raise APIError, "response has no body"
      end

      unless response[:body][:course_id]
        raise APIError, "response has no course id"
      end
      unless response[:body][:lesson_id]
        raise APIError, "response has no lesson id"
      end
      unless response[:body][:exercise_id]
        raise APIError, "response has no exercise id"
      end
      unless response[:body][:title]
        raise APIError, "response has no title"
      end
      unless response[:body][:instructions]
        raise APIError, "response has no instructions"
      end
      unless response[:body][:test_url]
        raise APIError, "response has no test url"
      end
      unless response[:body][:exercise_url]
        raise APIError, "response has no exercise url"
      end
      unless response[:body][:point_value]
        raise APIError, "response has no point value"
      end

      exercise = self.new(course_id: response[:body][:course_id],
        lesson_id: response[:body][:lesson_id],
        exercise_id: response[:body][:exercise_id],
        title: response[:body][:title],
        instructions: response[:body][:instructions],
        test_url: response[:body][:test_url],
        exercise_url: response[:body][:exercise_url],
        point_value: response[:body][:point_value])

      prefix = Config.instance.directory + "/" + exercise.hex_prefix

      test_file = get_file(exercise.test_url)
      test_path = prefix + File.basename(exercise.test_url)
      save_file(test_path, test_file)

      exercise_file = get_file(exercise.exercise_url)
      exercise_path = prefix + File.basename(exercise.exercise_url)
      save_file(exercise_path, exercise_file)

      exercise
    end

    def test(submission_path)
      # Run the test
      prefix = Config.instance.directory + "/" + hex_prefix

      test_path = prefix + File.basename(test_url)
      test_file = self.class.get_local_file(test_path)

      submission_file = self.class.get_local_file(submission_path)

      submission = submission_file
      eval(test_file)
    end

    def push(submission_path, user)
      submission = self.class.get_local_file(submission_path)

      response = Request.exercise_push(@course_id, @lesson_id, @exercise_id, submission, user)
      response
    end

    private

    def self.get_file(url)
      begin
        result = yield(Faraday.get(url).body)
      rescue Faraday::TimeoutError => e
        raise ConnectionError, 'connection timed out'
      rescue Faraday::ClientError => e
        raise ConnectionError
      end
      result
    end

    def self.get_local_file(path)
      unless path != nil
        raise ValidationError, "must be passed a path"
      end

      content = ''

      begin
        f = File.open(path, 'r')
      rescue
        raise ValidationError, "error opening file"
      end

      f.each_line do |line|
        content += line
      end

      content
    end

    def self.save_file(path, content)
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
