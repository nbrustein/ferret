require File.expand_path("../../ferret", __FILE__)

module Ferret::Feature
  
  def self.find(identifying_hash_or_key)
    key = identifying_hash_or_key.is_a?(Hash) ? get_key(identifying_hash_or_key) : identifying_hash_or_key
    hash = Ferret.adapter.find_feature(key)
    klass = hash.delete('_type').constantize
    klass.from_hash(hash)
  end
    
  def self.get_key(hash)
    [
      hash['feature_type'],
      hash['subject_uri'],
      hash['object_uri']
    ].join("~~~")
  end
  
end