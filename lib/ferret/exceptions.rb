require File.expand_path("../../ferret", __FILE__)

module Ferret
  
  class AdapterNotFound < RuntimeError
    def initialize(adapter_name)
      super("The adapter #{adapter_name.inspect} could not be found.")
    end
  end
  
  class ConfigNotFound < RuntimeError
    def initialize(config_name)
      super("No configuration found for #{config_name.inspect}.")
    end
  end
  
  class NotAndUpdate < RuntimeError
    def initialize(arg)
      super("Cannot create an instance of #{Ferret::Feature::Update} from #{arg.inspect}")
    end
  end
  
  class NoDefaultConfiguration < RuntimeError
    def initialize
      super("No default ferret configuration and none specified.")
    end
  end
  
  class InvalidFeatureUpdate < RuntimeError; end
  class InvalidFeature < RuntimeError; end
  class InvalidEvent < RuntimeError; end
  class MalformedFeatureValue < RuntimeError; end
  class UnexpectedEventType < RuntimeError; end
end