require File.expand_path("../../feature", __FILE__)

class Ferret::Feature::Update
  include ActiveModel::Model
  
  attr_accessor :time, :value, :feature, :new, :updated_at
  validates_presence_of :time, :value
  
  def initialize(attrs)
    super({
      'new' => true
    }.merge(attrs))
  end
  
  def dirty?
    self.new || false
  end
  
  def as_json
    {
      'time' => time.utc,
      'value' => value,
      'updated_at' => Time.now.utc
    }
  end
  
end