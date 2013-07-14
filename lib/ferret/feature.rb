require File.expand_path("../../ferret", __FILE__)

module Ferret::Feature
  
  def self.find_one(subject_uri, feature_type, object_uri, options = {})
    find(subject_uri, feature_type, [object_uri], options)[object_uri]
  end
  
  def self.find(subject_uri, feature_type, object_uris = :all, options = {})
    options['load_updates'] ||= :none
    unless object_uris.is_a?(Array) || object_uris == :all
      raise ArgumentError.new("object_uris must be an array or :all")
    end
    feature_hashes = Ferret.adapter.find_features(subject_uri, feature_type, object_uris, options)
    
    features = {}
    expected_object_uris = Set.new(object_uris == :all ? [] : object_uris)
    
    # initialize the features that already exist in the database
    feature_hashes.each do |hash|
      object_uri = hash['object_uri']
      features[object_uri] = from_hash(hash, options['load_updates'])
      expected_object_uris.delete object_uri
    end
    
    # initialize the features that currently have no updates in the database
    expected_object_uris.each do |object_uri|
      features[object_uri] = from_hash({
        'subject_uri' => subject_uri,
        'feature_type' => feature_type,
        'object_uri' => object_uri,
        'updates' => []
      }, :all)
    end
    
    features
  end
    
  def self.get_key(hash)
    [
      hash['feature_type'],
      hash['subject_uri'],
      hash['object_uri']
    ].join("~~~")
  end
  
  def self.get_identifying_hash(key)
    feature_type, subject_uri, object_uri = key.split("~~~")
    {
      'feature_type' => feature_type,
      'subject_uri' => subject_uri,
      'object_uri' => object_uri
    }
  end
  
  def self.from_hash(hash, load_updates_options)
    klass = feature_classes.detect { |klass| klass::FEATURE_TYPE == hash['feature_type']}
    raise Ferret::UnknownFeatureType.new(hash['feature_type']) unless klass
    updates = Ferret::Feature::Updates.from_hashes(hash['updates'], load_updates_options)
    klass.new(hash.merge({
      'updates' => updates
    }))
  end
  
  def self.feature_classes
    Ferret.configuration.feature_classes
  end
  
  def self.get_current_values(subject_uri, feature_type, object_uris = :all)
    values = {}
    find(subject_uri, feature_type, object_uris, {
      'load_updates' => :last
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