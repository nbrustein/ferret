require 'active_model'
require File.expand_path("../../event", __FILE__)
require 'active_support/core_ext/object/instance_variables'

class Ferret::Event::Base
  include ActiveModel::Model
  
  # FIXME: go back to json-schema so we can use it on the front-end
  attr_accessor :key, :start_time, :finish_time
  validates_presence_of :key, :start_time, :finish_time
  
  define_model_callbacks :save
  after_save :update_features
  
  def initialize(params)
    super(params)
    self.key ||= SecureRandom.uuid
  end
  
  def [](key)
    send(key.to_sym)
  end
  
  def update_features
    Ferret::Feature.update_features_for_event(self)
  end
  
  def save!
    raise Ferret::InvalidEvent.new(errors.full_messages) unless valid?
    run_callbacks :save do
      Ferret.adapter.save_event(self)
    end
  end
  
  def as_json
    instance_values.except("errors", "validation_context").merge({
      '_type' => self.class.name,
      'event_type' => self.class::EVENT_TYPE
    })
  end
  
end