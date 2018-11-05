require 'yaml'

module CodeCityCLI
  class Config
    attr_accessor :config_hash

    def initialize
      @config_hash = Hash.new
      load
    end

    def load
      f = config_file
      @config_hash = YAML.load(f)
      if !@config_hash
        @config_hash = Hash.new
      end
    end

    def save
      # Save the hash into the config file
      f = config_file('w')
      f.write(@config_hash.to_yaml)
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
