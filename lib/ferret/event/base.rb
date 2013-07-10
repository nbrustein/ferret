require 'active_model'
require File.expand_path("../../event", __FILE__)
require 'active_support/core_ext/object/instance_variables'

class Ferret::Event::Base
  include ActiveModel::Model
  
  attr_accessor :key
  validates_presence_of :key
  
  def initialize(params)
    super(params)
    self.key ||= SecureRandom.uuid
  end
  
  def save!
    raise Ferret::InvalidEvent.new(errors.full_messages) unless valid?
    Ferret.adapter.save_event(self)
  end
  
  def as_json
    instance_values.except("errors", "validation_context").merge({
      '_type' => self.class.name,
      'event_type' => self.class::EVENT_TYPE
    })
  end
  
end