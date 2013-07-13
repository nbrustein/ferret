require File.expand_path("../ferret_test_base", __FILE__)

class Ferret::EventSavingIntegrationTest < Ferret::FerretTestBase
  
  use_configuration "ferret_gem_test"
  
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