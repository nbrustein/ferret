require File.expand_path("../base", __FILE__)

class Ferret::Feature::Update::ByEvent < Ferret::Feature::Update::Base
  
  validates_presence_of :event_key
  
  def event_key
    metadata['event_key']
  end
  
end