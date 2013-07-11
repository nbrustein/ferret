require File.expand_path("../ferret_test_base", __FILE__)

class Ferret::EventSavingIntegrationTest < Ferret::FerretTestBase
  
  use_configuration "ferret_gem_test"
  
  class TestEvent < Ferret::Event::Base
    EVENT_TYPE = "test_event"

    attr_accessor :subject_uri, :object_uri, :inc
    validates_presence_of :subject_uri, :object_uri, :inc

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
  
  stub_feature_classes [TestFeature]
  
  def test_updating_a_feature_when_saving_an_event
    params = {
      'subject_uri' => 'subject_uri',
      'object_uri' => 'object_uri',
      'inc' => 1
    }
    assert_equal 0, Ferret::Subject.new('subject_uri').get_feature_value('test_feature', 'object_uri')
    TestEvent.new(params.merge('start_time' => Time.at(0), 'finish_time' => Time.at(1))).save!
    assert_equal 1, Ferret::Subject.new('subject_uri').get_feature_value('test_feature', 'object_uri')
    TestEvent.new(params.merge('start_time' => Time.at(2), 'finish_time' => Time.at(3))).save!
    assert_equal 2, Ferret::Subject.new('subject_uri').get_feature_value('test_feature', 'object_uri')
  end
  
end