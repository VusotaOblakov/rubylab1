require 'yaml'
require 'erb'
require 'json'

class AppConfigLoader
  attr_reader :config_data

  def initialize(config_file, config_dir)
    @config_file = config_file
    @config_dir = config_dir
    @config_data = {}
  end

  def self.load_libs(directory)
    required_libs = %w[date json] 
    required_libs.each { |lib| require lib }

    Dir[File.join(directory, '*.rb')].each do |file|
      require_relative file unless file == __FILE__
    end
  end
  
  def config
    load_default_config
    load_additional_configs
    yield(@config_data) if block_given?
    @config_data
  end

  def pretty_print_config_data
    puts JSON.pretty_generate(@config_data)
  end

  private

  def load_default_config
    erb_result = ERB.new(File.read(@config_file)).result
    @config_data.merge!(YAML.safe_load(erb_result))
  end

  def load_additional_configs
    Dir[File.join(@config_dir, '*.yaml')].each do |file|
      config = YAML.safe_load(File.read(file))
      @config_data.merge!(config) if config
    end
  end
end
