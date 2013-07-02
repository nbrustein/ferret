require File.expand_path("../../feature", __FILE__)
require File.expand_path("../update", __FILE__)

# has a subject_uri, a feature_type, and an object_uri
# has a default value
# can have any number of updates
class Ferret::Feature::Base
  include ActiveModel::Model
  
  Update = Ferret::Feature::Update
  
  delegate :adapter, :to => :configuration
  
  attr_accessor :subject_uri, :feature_type, :object_uri, :key, :updates, :revision
  validates_presence_of :subject_uri, :feature_type, :object_uri, :key, :updates, :revision
  
  define_model_callbacks :validate
  after_validate :validate_updates
  
  class << self
    
    delegate :adapter, :to => :configuration
    
    def configuration=(config_name)
      @configuration = Ferret::Configuration.load(config_name) 
    end
    alias :set_configuration :configuration= 
  
    def configuration
      if defined? @configuration
        @configuration
      elsif superclass.respond_to?(:configuration)
        superclass.configuration
      else
        @configuration = Ferret::Configuration.load_default
      end
    end
    
    def find(identifying_hash_or_key)
      key = identifying_hash_or_key.is_a?(Hash) ? get_key(identifying_hash_or_key) : identifying_hash_or_key
      hash = adapter.find_feature(key)
      from_hash(hash)
    end
    
    def get_key(hash)
      [
        hash['feature_type'],
        hash['subject_uri'],
        hash['object_uri']
      ].join("~~~")
    end
    
    def from_hash(hash)
      updates = hash['updates'] || []
      updates = updates.map do |update|
        if update.is_a?(Hash)
          self::Update.new(update)
        elsif update.is_a?(self.class::Update)
          update
        else
          raise Ferret::NotAndUpdate.new(update)
        end
      end
      new(hash.merge({
        'updates' => updates
      }))
    end
    
  end
  
  def initialize(attrs)
    super({
      'updates' => []
    }.merge(attrs))
    self.feature_type = self.class::FEATURE_TYPE
    self.revision = 0 if self.revision.nil?
  end
  
  def new?
    revision == 0
  end
  
  def dirty?
    return true if new?
    return if !!updates.detect(&:dirty?)
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
    adapter.save_feature(self)
  end
  
  def run_validations!
    run_callbacks :validate do
      super
    end
  end
  
  def configuration
    self.class.configuration
  end
  
  def adapter
    self.class.adapter
  end
  
  def as_json
    identifying_hash(true).merge({
      'key' => key,
      'updates' => updates.map(&:as_json)
    })
  end
  
  def key
    self.class.get_key(identifying_hash)
  end
  
  private
  def validate_updates
    updates.each_with_index do |update, i|
      unless update.valid?
        update.errors.each do |key, message|
          errors.add("updates[#{i}]:#{key}", message)
        end
      end
    end
  end
  
end