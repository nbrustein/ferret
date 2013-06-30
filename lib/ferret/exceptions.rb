require File.expand_path("../../ferret", __FILE__)

module Ferret
  
  class AdapterNotFound < RuntimeError
    def new(adapter_name)
      super("The adapter #{adapter_name.inspect} could not be found.")
    end
  end
  
  class ConfigNotFound < RuntimeError
    def new(config_name)
      super("No configuration found for #{config_name.inspect}.")
    end
  end
  
  class InvalidFeatureUpdate < RuntimeError; end
  class InvalidFeature < RuntimeError; end
  
end