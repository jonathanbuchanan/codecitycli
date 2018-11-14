module CodeCityCLI
  class Exercise
    attr_accessor :id
    attr_accessor :course_id
    attr_accessor :lesson_id
    attr_accessor :title
    attr_accessor :instructions
    attr_accessor :test
    attr_accessor :value

    def initialize(args)
      self.id = args[:id] if args[:id]
      self.course_id = args[:course_id] if args[:course_id]
      self.lesson_id = args[:lesson_id] if args[:lesson_id]
      self.title = args[:title] if args[:title]
      self.instructions = args[:instructions] if args[:instructions]
      self.test = args[:test] if args[:test]
      self.value = args[:value] if args[:value]
    end

    def get(user)
      # GET /courses/course_id/lessons/lesson_id/exercises/exercise_id
    end

    def self.index(user, course_id, lesson_id)
      # GET /courses/course_id/lessons/lesson_id/exercises
      # return exercises
    end

    def test(user, submission_link)
      # POST /courses/course_id/lessons/lesson_id/exercises/exercise_id/test?submission_link=a
      # return result
    end
  end
end
