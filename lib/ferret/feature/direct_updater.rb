require File.expand_path("../../feature", __FILE__)

class Ferret::Feature::DirectUpdater
  
  attr_reader :feature, :new_value, :time, :metadata, :current_revision
  
  def initialize(identifying_hash, current_revision, new_value, time, metadata = {})
    @feature = Ferret::Feature.find_one(
      identifying_hash['subject_uri'], 
      identifying_hash['feature_type'], 
      identifying_hash['object_uri'], 
      {'updates_limit' => 1}
    )
    @current_revision = current_revision
    @new_value = new_value
    @time = time
    @metadata = metadata
  end
  
  def success?
    @success
  end
  
  def update
    if @feature.revision != current_revision
      raise Ferret::OutOfDateFeature.new("DirectUpdater cannot update a feature with an unexpected revision. #{@feature.revision} != #{current_revision}")
    end
    
    if @feature.last_update && @feature.last_update.time >= time
      raise Ferret::OutOfDateFeature.new("DirectUpdater cannot update feature that already has an update at a later time")
    end
    
    new_update = Ferret::Feature::Update::Direct.new({
      'time' => time,
      'value' => new_value,
      'metadata' => metadata
    })
    
    @feature.add_update(new_update)
    
    if @feature.save!
      # save an event
      @success = true
    else
      
      @sucess = false
    end
  end
  
  
  
end