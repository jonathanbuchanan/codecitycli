require 'yaml'
require 'singleton'

module CodeCityCLI
  class Config
    include Singleton
    attr_accessor :api_key
    attr_accessor :directory

    def initialize
      load
    end

    def login(username, password)
      # Send a login request to the server and store the token
    end

    def load
      f = config_file
      config_hash = YAML.load(f)
      if config_hash.is_a? Hash
        @api_key = config_hash[:api_key] if config_hash[:api_key]
        @directory = config_hash[:directory] if config_hash[:directory]
      end
    end

    def save
      # Save the hash into the config file
      f = config_file('w')
      config_hash = Hash.new
      config_hash[:api_key] = @api_key if @api_key
      config_hash[:directory] = @directory if @directory
      f.write(config_hash.to_yaml)
    end

    private

    def config_file(mode = 'r')
      path = Dir.home + '/.codecity.config'
      if !File.exists?(path)
        File.open(path, 'w') {}
      end
      File.open(path, mode)
    end
  end
end
