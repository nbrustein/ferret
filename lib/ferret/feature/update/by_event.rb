require File.expand_path("../base", __FILE__)

class Ferret::Feature::Update::ByEvent < Ferret::Feature::Update::Base
  
  validates_presence_of :event_id
  
  def event_id
    metadata['event_id']
  end
  
end