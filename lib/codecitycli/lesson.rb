module CodeCityCLI
  class Lesson
    attr_accessor :id
    attr_accessor :title
    attr_accessor :course_id

    def initialize(args)
      self.id = args[:id] if args[:id]
      self.title = args[:title] if args[:title]
      self.course_id = args[:course_id] if args[:course_id]
    end

    def self.get(course_id, id, user)
      response = Request.get("/courses/#{course_id}/lessons/#{id}", {}, user.account.token.headers)[:body]
      Lesson.new(response)
    end
  end
end
