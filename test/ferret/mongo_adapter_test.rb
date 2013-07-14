require File.expand_path("../ferret_test_base", __FILE__)

# to skip this test, add 'mongo_adapter_test: ~' to your ferret.yml
if Ferret::Configuration.has_config?('mongo_adapter_test')
  
  class Ferret::MongoAdapterTest < Ferret::FerretTestBase
  
    use_configuration "mongo_adapter_test"
    
    class TestEvent < Ferret::Event::Base
      EVENT_TYPE = "mongo_adapter_test_event"
      
      key :prop, String
    end
    
    def test_saving_and_retrieving_a_feature
      stub_feature_classes [TestFeature]
      Time.stubs(:now).returns(Time.at(0).utc) # make sure all updates have the same updated_at
      feature = TestFeature.new({
        'subject_uri' => 's',
        'object_uri' => 'o',
        'updates' => Ferret::Feature::Updates.new([
          Ferret::Feature::Update::Direct.new({
            'time' => Time.at(0).utc,
            'value' => 'value'
          })
        ], [])
      })
      feature.save!
      assert_equal 1, feature.revision
      reloaded = Ferret::Feature.find_one('s', feature.feature_type, 'o')
      assert_equal TestFeature, reloaded.class, "Unexpected class for reloaded feature"
      assert_equal feature.as_json, reloaded.as_json
    end
    
    def test_saving_and_retrieving_an_event
      event = TestEvent.new({
        'prop' => 'value',
        'key' => 'key',
        'start_time' => Time.at(0),
        'finish_time' => Time.at(1)
      })
      event.save!
      reloaded = Ferret::Event.find(event.key)
      assert_equal TestEvent, reloaded.class
      assert_equal event.as_json, reloaded.as_json
    end
  
  end
  
end