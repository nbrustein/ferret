require 'test/unit'
require 'ferret'

class Ferret::EventSavingIntegrationTest < Test::Unit::TestCase
  
  class TestEvent < Ferret::Event::Base
    EVENT_TYPE = "test_event"

    self.json_schema = {
      "type" => "object",
      "required" => ["subject_uri", "object_uri", "new_value"],
      "optional" => ["optional"],
      "properties" => {
        "subject_uri" => {"type" => "string"},
        "object_uri" => {"type" => "string"},
        "it" => {"type" => "integer"},
        "optional" => {"type" => "string"},
      }
    }

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
      current_value + event['new_value']
    end
    
    def self.default_value
      0
    end

  end
  
  def test_updating_a_feature_when_saving_an_event
    params = {
      'subject_uri' => 'subject_uri',
      'object_uri' => 'object_uri',
      'it' => 1
    }
    TestEvent.new(params).save!
    assert_equal 1, Subject.new('subject_uri').get_feature('test_feature', 'object_uri')
    TestEvent.new(params).save!
    assert_equal 2, Subject.new('subject_uri').get_feature('test_feature', 'object_uri')
  end
  
end