require 'codecitycli/version'
require 'codecitycli/config'
require 'thor'

module CodeCityCLI
  class CLI < Thor
    desc 'config', 'configure settings for the client'
    option :api_key, type: :string
    option :directory, type: :string
    def config
      config = Config.new

      config.api_key = options[:api_key] if options[:api_key]
      config.directory = options[:directory] if options[:directory]

      config.save
    end

    desc 'login USERNAME PASSWORD', 'log into code city with USERNAME and PASSWORD'
    def login(username, password)
      config = Config.new

      config.login(username, password)

      config.save
    end
  end
end
