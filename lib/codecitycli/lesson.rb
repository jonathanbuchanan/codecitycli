module CodeCityCLI
  class Exercise
    attr_accessor :title
    attr_accessor :id
    attr_accessor :lesson_id
    attr_accessor :course_id
    attr_accessor :value
    attr_accessor :slides

    def initialize(args)
      self.title = args[:title] if args[:title]
      self.id = args[:id] if args[:id]
      self.lesson_id = args[:lesson_id] if args[:lesson_id]
      self.course_id = args[:course_id] if args[:course_id]
      self.value = args[:value] if args[:value]
      self.slides = args[:slides] if args[:slides]
    end

    def show(user)
      response = Request.get("/courses/#{self.course_id}/lessons/#{self.lesson_id}/exercises/#{self.id}", {}, user.account.token.headers)[:body]

      test_file = get_file(response[:test_path])
      exercise_file = get_file(response[:exercise_path])

      test_path = Config.instance.directory + '/' + course_name + '/' + lesson_name + '/' + response[:test_name]
      exercise_path = Config.instance.directory + '/' + course_name + '/' + lesson_name + '/' + response[:exercise_name]

      save_file(test_path, test_file)
      save_file(exercise_path, exercise_file)

      return
    end

    def fetch(user)
      response = Request.get("/courses/#{self.course_id}/lessons/#{self.lesson_id}/exercises/#{self.id}", {}, user.account.token.headers)[:body]
    end

    def push(submission_path, user)
      submission = get_local_file(submission_path)

      response = Request.post("/courses/#{self.course_id}/lessons/#{self.lesson_id}/exercises/push", { id: self.id, submission: submission }, user.account.token.headers)
      response[:body]
    end

    def test(submission_path)
      # Run the test
    end

    def self.index(user, course_id)
      # GET /courses/course_id/lessons/
      # return exercises
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
      # TODO: Fetch course name
      'course'
    end

    def lesson_name
      # TODO: Fetch lesson name
      'lesson'
    end
  end
end
