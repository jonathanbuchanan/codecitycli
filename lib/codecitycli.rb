require 'codecitycli/version'
require 'codecitycli/config'
require 'thor'

module CodeCityCLI
  class CLI < Thor
    desc 'config', 'configure settings for the client'
    option :api_key, type: :string
    def config
      config = Config.new
      config.config_hash[:api_key] = options[:api_key]
      config.save
    end
  end
end
