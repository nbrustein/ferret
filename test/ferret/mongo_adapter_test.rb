require 'test/unit'
require 'ferret'

# to skip this test, add 'mongo_adapter_test: ~' to your ferret.yml
if Ferret::Configuration.has_config?('mongo_adapter_test')
  
  class Ferret::MongoAdapterTest < Test::Unit::TestCase
  
    class TestFeature < Ferret::Feature::Base
      FEATURE_TYPE = "test_feature"
      
      set_configuration "mongo_adapter_test"
    end
  
    def test_saving_a_new_feature
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
      reloaded = TestFeature.find(feature.identifying_hash)
      assert_equal feature.as_json, reloaded.as_json
    end
  
  end
  
end