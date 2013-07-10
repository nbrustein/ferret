require 'test/unit'
require 'ferret'

# to skip this test, add 'mongo_adapter_test: ~' to your ferret.yml
if Ferret::Configuration.has_config?('mongo_adapter_test')
  
  class Ferret::MongoAdapterTest < Test::Unit::TestCase
  
    class TestFeature < Ferret::Feature::Base
      FEATURE_TYPE = "test_feature"
    end
    
    class TestEvent < Ferret::Event::Base
      EVENT_TYPE = "test_event"
      
      attr_accessor :prop
      validates_presence_of :prop
    end
    
    def teardown
      Ferret.with_configuration("mongo_adapter_test") do
        Ferret.clear_databases
      end
    end
  
    def test_saving_and_retrieving_a_feature
      Ferret.with_configuration("mongo_adapter_test") do 
        feature = TestFeature.new({
          'subject_uri' => 's',
          'object_uri' => 'o',
          'updates' => [
            TestFeature::Update.new({
              'time' => Time.at(0).utc,
              'value' => 'value'
            })
          ]
        })
        feature.save!
        assert_equal 1, feature.revision
        reloaded = Ferret::Feature.find(feature.identifying_hash)
        assert_equal TestFeature, reloaded.class
        assert_equal feature.as_json, reloaded.as_json
      end
    end
    
    def test_saving_and_retrieving_an_event
      Ferret.with_configuration("mongo_adapter_test") do 
        event = TestEvent.new({
          'prop' => 'value',
          'key' => 'key'
        })
        event.save!
        reloaded = Ferret::Event.find(event.key)
        assert_equal TestEvent, reloaded.class
        assert_equal event.as_json, reloaded.as_json
      end
    end
  
  end
  
end