require 'test/unit'
require 'ferret'
require 'active_support/test_case'
require 'mocha/setup'

class Ferret::FerretTestBase < ActiveSupport::TestCase
  
  setup :set_configuration
  teardown :clear_databases_and_reset_configuration
  
  def self.inherited(subclass)
    super
    subclass.stub_feature_classes [TestFeature]
    subclass.use_configuration "ferret_gem_test"
  end
  
  class TestEvent < Ferret::Event::Base
    EVENT_TYPE = "test_event"
  
    key :subject_uri, String
    key :object_uri, String
    key :inc, Numeric
  end
  
  class TestFeature < Ferret::Feature::Base
    FEATURE_TYPE = "test_feature"
    
    def self.event_types 
      [TestEvent::EVENT_TYPE]
    end
  
    def self.subject_uris_for_event(event)
      event['subject_uri']
    end
  
    def self.object_uris_for_subject_and_event(subject_uri, event)
      event['object_uri']
    end
  
    def self.update(current_value, subject_uri, object_uri, event)
      current_value + event['inc']
    end
    
    def self.default_value
      0
    end
  
  end
  
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
  
  def get_event(attrs = {})
    TestEvent.new({
      'subject_uri' => 'subject_uri',
      'object_uri' => 'object_uri',
      'inc' => 1
    }.merge(attrs))
  end
  
  def get_identifying_hash(attrs = {})
    {
      'subject_uri' => 'subject_uri', 
      'feature_type' => TestFeature::FEATURE_TYPE, 
      'object_uri' => 'object_uri'
    }.merge(attrs)
  end
  
end