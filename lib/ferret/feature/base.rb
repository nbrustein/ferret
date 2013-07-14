require 'active_model'
require 'active_support/core_ext/class/subclasses'
require File.expand_path("../../feature", __FILE__)
require File.expand_path("../update", __FILE__)

# has a subject_uri, a feature_type, and an object_uri
# has a default value
# can have any number of updates
class Ferret::Feature::Base
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  
  Update = Ferret::Feature::Update
  
  attr_accessor :subject_uri, :feature_type, :object_uri, :key, :updates, :revision
  validates_presence_of :subject_uri, :feature_type, :object_uri, :key, :updates, :revision
  delegate :all_updates_loaded?, :to => :updates
  
  before_validation :validate_updates
  
  class << self
    
    def update_for_event(event)
      return unless self.event_types.include?(event.event_type)
      subject_uris = self.subject_uris_for_event(event)
      return if subject_uris.nil?
      subject_uris = [subject_uris] unless subject_uris.is_a?(Array)
      
      subject_uris.each do |subject_uri|
        object_uris = object_uris_for_subject_and_event(subject_uri, event)
        next if object_uris.nil?
        object_uris = [object_uris] unless object_uris.is_a?(Array)
        features = Ferret::Feature.find(
          subject_uri, 
          self::FEATURE_TYPE, 
          object_uris,
          {
            'load_updates' => {'last_before' => event.finish_time, 'upto' => :now}
          })
        object_uris.each do |object_uri|
          features[object_uri].update_for_event(event)
        end
      end
    end
    
    def default_value
      nil
    end
    
    # interface methods
    ['event_types', 'subject_uris_for_event', 'object_uris_for_subject_and_event', 'update'].each do |meth|
      define_method(meth.to_sym) do |*args|
        raise NotImplementedError.new("Subclasses of #{Ferret::Feature::Base.name} should define #{meth.inspect}. #{self.name} does not.")
      end  
    end
    
  end
  
  def initialize(attrs)
    super
    self.feature_type = self.class::FEATURE_TYPE
    self.revision = 0 if self.revision.nil?
  end
  
  def new?
    revision == 0
  end
  
  def dirty?
    return true if new?
    return !!updates.detect(&:dirty?)
  end
  
  def only_last_update_is_dirty?
    return false if new?
    return updates.last.dirty? && (updates.slice(0, updates.size - 1)).map(&:dirty?).uniq == [false]
  end
  
  def identifying_hash(include_revision = false)
    params = {
      'subject_uri' => subject_uri,
      'feature_type' => feature_type,
      'object_uri' => object_uri
    }
    params.merge!({'revision' => revision}) if include_revision
    params
  end
  
  def save!
    raise Ferret::InvalidFeature.new(errors.full_messages) unless valid?
    Ferret.adapter.save_feature(self) if dirty?
  end
  
  def as_json
    identifying_hash(true).merge({
      'key' => key,
      'updates' => updates.map(&:as_json)
    })
  end
  
  def key
    Ferret::Feature.get_key(identifying_hash)
  end
  
  def current_value
    updates.last.nil? ? default_value : updates.last.value
  end
  
  def default_value
    self.class.default_value
  end
  
  def update_for_event(event, attempt = 1)
    previous_update, previous_update_index = nil, -1
    
    update_time = event.finish_time.utc
    (updates.size - 1).downto(0) do |i|
      update = updates[i]
      if update.time <= update_time
        previous_update = update
        previous_update_index = i
        break
      end
    end
    
    previous_value = previous_update.nil? ? default_value : previous_update.value
    
    new_update = Ferret::Feature::Update::ByEvent.new({
      'time' => update_time,
      'value' => self.class.update(previous_value, subject_uri, object_uri, event),
      'metadata' => {'event_key' => event.key}
    })
    self.updates.insert(previous_update_index + 1, new_update)
    
    begin
      save!
    rescue Ferret::OutOfDateFeature => e
      # FIXME: log something whenever this happens, raise after n attempts
      reload
      update_for_event(event, attempt += 1)
    end
  end
  
  def add_update(update)
    if last_update && update.time <= last_update.time
      OutOfDateFeature.new("Cannot add an update when there is already an update at a later time.")
    end
    
    self.updates << update
  end
  
  def last_update
    updates.last
  end
  
  private
  def validate_updates
    if updates.is_a?(Ferret::Feature::Updates)
      unless updates.valid?
        updates.errors.each do |key, message|
          errors.add("updates:#{key}", message)
        end
      end
    else  
      errors.add("updates", "is not an instance of Ferret::Feature::Updates. Is #{self.updates.class}")
    end
  end
  
end