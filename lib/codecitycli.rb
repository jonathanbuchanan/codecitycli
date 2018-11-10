require 'codecitycli/version'
require 'codecitycli/config'
require 'thor'

module CodeCityCLI
  class CLI < Thor
    desc 'config', 'configure settings for the client'
    option :api_key, type: :string
    option :directory, type: :string
    def config
      Config.instance.api_key = options[:api_key] if options[:api_key]
      Config.instance.directory = options[:directory] if options[:directory]

      Config.instance.save
    end

    desc 'login USERNAME PASSWORD', 'log into code city with USERNAME and PASSWORD'
    def login(username, password)
      Config.instance.login(username, password)

      Config.instance.save
    end
  end
end
