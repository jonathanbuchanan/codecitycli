module CodeCityCLI
  class Exercise
    attr_accessor :title
    attr_accessor :id
    attr_accessor :course_id
    attr_accessor :value
    attr_accessor :slides

    def initialize(args)
      self.title = args[:title] if args[:title]
      self.id = args[:id] if args[:id]
      self.course_id = args[:course_id] if args[:course_id]
      self.value = args[:value] if args[:value]
      self.slides = args[:slides] if args[:slides]
    end

    def get(user)
      # GET /courses/course_id/lessons/lesson_id/
    end

    def self.index(user, course_id)
      # GET /courses/course_id/lessons/
      # return exercises
    end
  end
end
