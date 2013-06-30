require File.expand_path("../../feature", __FILE__)

class Ferret::Feature::Update
  include ActiveModel::Model
  
  attr_accessor :time, :value, :feature, :new
  validates_presence_of :time, :value
  
  def initialize(attrs)
    super({
      'new' => true
    }.merge(attrs))
  end
  
end