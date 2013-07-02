require 'yaml'
require File.expand_path("../../ferret", __FILE__)

class Ferret::Configuration
  
  def self.has_config?(config_name)
    !!config_from_yaml[config_name]
  end
  
  def self.load_default
    load(Rails.env)
  end
  
  def self.load(config_name)
    raise Ferret::ConfigNotFound.new(config_name) unless config = config_from_yaml[config_name]
    new config
  end
  
  private
  def self.config_from_yaml
    return @config if defined? @config
    files = []
    dirs = [File.join(Ferret.root, "config")]
    if const_defined? :Rails
      dirs << Rails.root.join("config")
    end
    
    config = {}
    ['ferret.defaults.yml', 'ferret.yml'].each do |filename|
      dirs.each do |dir|
        path = File.join(dir, filename)
        config.deep_merge!(YAML::load_file(path)) if File.exists?(path)
      end
    end
    
    @config = config
  end
  
  public
  def initialize(config)
    @config = config
  end
  
  def adapter
    @adapter ||= Ferret::Adapters.get(@config['adapter']).new(@config)
  end
  
end