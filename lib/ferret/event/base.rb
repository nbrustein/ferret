require 'active_model'
require File.expand_path("../../event", __FILE__)
require File.expand_path("../../adaptable", __FILE__)
require 'json-schema'

class Ferret::Event::Base
  include ActiveModel::Model
  include Ferret::Adaptable
  
  attr_accessor :key
  
  class << self
    def clear_collection
      adapter.events_collection.remove
    end
    
    def find(key)
      hash = adapter.find_event(key)
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
  
  attr_accessor :key
  validates_presence_of :key
  
  def initialize(params)
    super(params)
    self.key ||= SecureRandom.uuid
  end
  
  def save!
    raise Ferret::InvalidEvent.new(errors.full_messages) unless valid?
    adapter.save_event(self)
  end
  
  def as_json
    instance_values.except("errors", "validation_context").merge({
      '_type' => self.class.name,
      'event_type' => self.class::EVENT_TYPE
    })
  end
  
end