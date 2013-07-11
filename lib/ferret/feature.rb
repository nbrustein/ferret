require File.expand_path("../../ferret", __FILE__)

module Ferret::Feature
  
  def self.find(identifying_hash_or_key)
    key = identifying_hash_or_key.is_a?(Hash) ? get_key(identifying_hash_or_key) : identifying_hash_or_key
    from_hash Ferret.adapter.find_feature(key)
  end
    
  def self.get_key(hash)
    [
      hash['feature_type'],
      hash['subject_uri'],
      hash['object_uri']
    ].join("~~~")
  end
  
  def self.from_hash(hash)
    klass = feature_classes.detect { |klass| klass::FEATURE_TYPE == hash['feature_type']}
    raise Ferret::UnknownFeatureType.new(hash['feature_type']) unless klass
    klass.from_hash(hash)
  end
  
  def self.feature_classes
    # FIXME: do we really want to rely on subclasses here?  This leaves us open
    # to nastiness from leftover side effects in tests.  Just puts the wrong kind of
    # responsibility on a global
    Ferret::Feature::Base.subclasses
  end
  
  def self.get_features(subject_uri, feature_type, object_uris = :all, options = {})
    feature_hashes = Ferret.adapter.find_features(subject_uri, feature_type, object_uris, options)
    
    features = {}
    expected_object_uris = Set.new(object_uris == :all ? [] : object_uris)
    feature_hashes.each do |hash|
      object_uri = hash['object_uri']
      hash['updates'].each { |update| update['new'] = false }
      features[object_uri] = from_hash(hash)
      expected_object_uris.delete object_uri
    end
    
    expected_object_uris.each do |object_uri|
      features[object_uri] = from_hash({
        'subject_uri' => subject_uri,
        'feature_type' => feature_type,
        'object_uri' => object_uri,
        'updates' => []
      })
    end
    
    features
  end
  
  def self.get_current_values(subject_uri, feature_type, object_uris = :all)
    values = {}
    get_features(subject_uri, feature_type, object_uris, {
      'updates_limit' => 1
    }).each do |object_uri, feature|
      values[object_uri] = feature.current_value
    end
    values
  end
  
  def self.update_features_for_event(event)
    feature_classes.each do |feature_class|
      feature_class.update_for_event(event)
    end
  end
  
end