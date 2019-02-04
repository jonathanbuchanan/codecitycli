require 'yaml'
require 'singleton'

module CodeCityCLI
  class Config
    private

    def self.config_attributes(attributes)
      attributes.each do |attr|
        attr_accessor attr[:attribute]
      end
      @@attributes = attributes
    end

    def self.default_directory
      Dir.home
    end

    public
    include Singleton
    config_attributes([
      { attribute: :user_type },
      { attribute: :user_id },
      { attribute: :organization_id },
      { attribute: :token },
      { attribute: :directory, default: default_directory }
    ])

    def initialize
      self.load
    end

    def load
      f = config_file
      config_hash = YAML.load(f)
      if config_hash.is_a? Hash
        config_hash.each do |key, value|
          self.instance_variable_set("@#{key.to_s}", value)
        end
      end
      @@attributes.each do |attr|
        if !self.instance_variable_defined?("@#{attr[:attribute].to_s}") and attr.key? :default
          self.instance_variable_set("@#{attr[:attribute].to_s}", attr[:default])
        end
      end
    end

    def save
      # Save the hash into the config file
      f = config_file('w')
      config_hash = Hash.new
      @@attributes.each do |attribute|
        attr = attribute[:attribute]
        config_hash[attr] = self.instance_variable_get("@#{attr.to_s}")
      end
      f.write(config_hash.to_yaml)
    end

    private

    def config_file(mode = 'r')
      path = Dir.home + '/.codecity.config'
      if !File.exist?(path)
        File.open(path, 'w') {}
      end
      File.open(path, mode)
    end
  end
end
