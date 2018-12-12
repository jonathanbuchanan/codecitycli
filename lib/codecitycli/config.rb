require 'yaml'
require 'singleton'

module CodeCityCLI
  class Config
    include Singleton
    attr_accessor :user_type
    attr_accessor :user_id
    attr_accessor :token
    attr_accessor :directory

    def initialize
      self.load
    end

    def login(username, password)
      # Send a login request to the server and store the token
    end

    def load
      f = config_file
      config_hash = YAML.load(f)
      if config_hash.is_a? Hash
        @user_type = config_hash[:user_type] if config_hash[:user_type]
        @user_id = config_hash[:user_id] if config_hash[:user_id]
        @token = config_hash[:token] if config_hash[:token]
        @directory = config_hash[:directory] if config_hash[:directory]
      end
    end

    def save
      # Save the hash into the config file
      f = config_file('w')
      config_hash = Hash.new
      config_hash[:user_type] = @user_type if @user_type
      config_hash[:user_id] = @user_id if @user_id
      config_hash[:token] = @token if @token
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
