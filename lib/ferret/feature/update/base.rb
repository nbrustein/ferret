require File.expand_path("../../update", __FILE__)

class Ferret::Feature::Update::Base
  include ActiveModel::Model
  
  attr_accessor :time, :value, :feature, :new, :updated_at, :metadata, :_type
  validates_presence_of :time, :value, :metadata, :_type
  
  def initialize(attrs)
    super({
      'new' => true,
      'metadata' => {},
      '_type' => self.class.name
    }.merge(attrs))
  end
  
  def dirty?
    self.new || false
  end
  
  def as_json
    {
      'time' => time.utc,
      'value' => value,
      'updated_at' => Time.now.utc,
      'metadata' => metadata,
      '_type' => _type
    }
  end
  
end