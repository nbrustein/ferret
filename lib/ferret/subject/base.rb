require 'active_model'
require File.expand_path("../../subject", __FILE__)

class Ferret::Subject::Base
  include ActiveModel::Model
  
  attr_reader :subject_uri
  
  def initialize(subject_uri)
    @subject_uri = subject_uri
    @loaded_features = Hash.new { |hash, feature_type| hash[feature_type] = {}}
  end
  
  def get_feature(feature_type, object_uri)
    if feature_loaded?(feature_type, object_uri)
      return get_loaded_feature(feature_type, object_uri)
    else 
      load_features(feature_type, [object_uri])
      return get_feature(feature_type, object_uri)
    end
  end
  
  def feature_loaded?(feature_type, object_uri)
    @loaded_features[feature_type].key?(object_uri)
  end
  
  def load_features(feature_type, object_uris)
    Ferret::Feature.get_current_values(subject_uri, feature_type, object_uris).each do |object_uri, value|
      @loaded_features[feature_type][object_uri] = value
    end
  end
end