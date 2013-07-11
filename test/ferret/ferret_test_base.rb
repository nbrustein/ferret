require 'test/unit'
require 'ferret'
require 'active_support/test_case'
require 'mocha/setup'

class Ferret::FerretTestBase < ActiveSupport::TestCase
  
  setup :set_configuration
  teardown :clear_databases_and_reset_configuration
  
  class << self
    
    attr_reader :config_name

    def use_configuration(config_name)
      @config_name = config_name
    end
    
    def stub_feature_classes(classes)
      setup(Proc.new {
        Ferret::Feature.stubs(:feature_classes).returns(classes)
      })
    end
    
  end
  
  def stub_feature_classes(classes)
    Ferret::Feature.stubs(:feature_classes).returns(classes)
  end
  
  def set_configuration
    return unless self.class.config_name
    @original_configuration = Ferret.configuration(false)
    Ferret.set_configuration(self.class.config_name)
  end
  
  def clear_databases_and_reset_configuration
    return unless self.class.config_name
    Ferret.clear_databases
    Ferret.set_configuration(@original_configuration)
  end
  
end