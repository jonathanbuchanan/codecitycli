require 'thor'

module CodeCityCLI
  class Course
    attr_accessor :title
    attr_accessor :id
    attr_accessor :repo_link

    def initialize
    end
  end

  module CLI
    class Course < Thor
      desc 'add COURSE', 'adds a course'
      def add(course)
      end

      desc 'remove COURSE', 'removes a course'
      def remove(course)
      end

      desc 'list', 'lists courses'
      def list
      end
    end
  end
end
