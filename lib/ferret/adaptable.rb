require File.expand_path("../../ferret", __FILE__)

module Ferret::Adaptable
  
  def self.included(target)
    target.send(:extend, Ferret::AdaptableClassMethods)
    target.send(:include, ActiveModel::Validations::Callbacks)
  end
  
  def configuration
    self.class.configuration
  end
  
  def adapter
    self.class.adapter
  end
  
end

module Ferret::AdaptableClassMethods
  
  def set_configuration(config_name)
    @configuration = Ferret::Configuration.load(config_name) 
  end

  def configuration
    if defined? @configuration
      @configuration
    elsif superclass.respond_to?(:configuration)
      superclass.configuration
    else
      @configuration = Ferret::Configuration.load_default
    end
  end
  
  def adapter
    configuration.adapter
  end
  
end