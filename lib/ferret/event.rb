require File.expand_path("../../ferret", __FILE__)

module Ferret::Event
  
  def self.find(key)
    hash = Ferret.adapter.find_event(key)
    klass = hash.delete('_type').constantize
    
    # quick sanity check that the event_type matches the klass defined in _type
    expected_type = klass::EVENT_TYPE
    event_type = hash.delete('event_type')
    unless expected_type == event_type  
      raise Ferret::UnexpectedEventType.new("Expected instance of #{klass} to have type #{expected_type.inspect} but had #{event_type.inspect}")
    end
    
    klass.new(hash)
  end
  
end