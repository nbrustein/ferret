require 'active_model'
require File.expand_path("../../event", __FILE__)
require 'active_support/core_ext/object/instance_variables'
require 'active_model/json/schema'

class Ferret::Event::Base
  include ActiveModel::Model
  include ActiveModel::JSON::Schema
  
  define_model_callbacks :save
  after_save :update_features
  
  key :key, String
  key :start_time, Time
  key :finish_time, Time
  key :event_type, String
  key :_type, String
  
  def initialize(params)
    super(params)
    self.key ||= SecureRandom.uuid
    self._type = self.class.name
    self.event_type = self.class::EVENT_TYPE
  end
  
  def [](key)
    respond_to?(key.to_sym) ? send(key.to_sym) : nil
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
  
end