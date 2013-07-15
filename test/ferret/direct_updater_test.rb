require File.expand_path("../ferret_test_base", __FILE__)

class Ferret::DirectUpdaterTest < Ferret::FerretTestBase
  
  def test_direct_updater_updates_feature
    Ferret::Feature::DirectUpdater.new(
      get_identifying_hash, 
      0,
      1,
      Time.at(0),
      {'key' => 'value'}
    ).update
    assert_equal 1, Ferret::Subject.new('subject_uri').get_feature_value(TestFeature::FEATURE_TYPE, 'object_uri')
    
    Ferret::Feature::DirectUpdater.new(
      get_identifying_hash, 
      1,
      2,
      Time.at(1),
      {'key' => 'value'}
    ).update
    assert_equal 2, Ferret::Subject.new('subject_uri').get_feature_value(TestFeature::FEATURE_TYPE, 'object_uri')
  end
  
  def test_direct_updater_cannot_update_feature_with_unexpected_revision
    Ferret::Feature::DirectUpdater.new(
      get_identifying_hash, 
      0,
      1,
      Time.at(0),
      {'key' => 'value'}
    ).update
    assert_equal 1, Ferret::Subject.new('subject_uri').get_feature_value(TestFeature::FEATURE_TYPE, 'object_uri')
    
    err = assert_raises(Ferret::OutOfDateFeature) do 
      Ferret::Feature::DirectUpdater.new(
        get_identifying_hash, 
        0, # revision is now 1, so update should fail
        2,
        Time.at(1),
        {'key' => 'value'}
      ).update
    end
    assert_equal "DirectUpdater cannot update a feature with an unexpected revision. 1 != 0", err.message
  end
  
  def test_direct_updater_cannot_update_feature_that_has_an_update_at_a_later_time
    
  end
  
end