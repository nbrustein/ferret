require File.expand_path("../../feature", __FILE__)

module Ferret::Feature::Update
  
  def self.from_hash(hash)
    klass = hash['_type'].constantize
    klass.new(hash)
  end
    
end