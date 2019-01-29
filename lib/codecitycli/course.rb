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
      Request.post("/courses/", { course: get_params }, user.account.token.headers)
    end

    def update(user)
      # PUT /courses/course_id?repo_link=a&title=b
      Request.put("/courses/#{self.id}", { course: get_params }, user.account.token.headers)
    end

    def delete(user)
      # DELETE /courses/course_id
      Request.delete("/courses/#{self.id}", {}, user.account.token.headers)
    end

    def self.get(id, user)
      # GET /courses/#{id}
      raw_course = Request.get("/courses/#{id}", {}, user.account.token.headers)[:body]
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
end
