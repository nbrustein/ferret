require File.expand_path("../../feature", __FILE__)
require File.expand_path("../update", __FILE__)

# has a subject_uri, a feature_type, and an object_uri
# has a default value
# can have any number of updates
class Ferret::Feature::Base
  include ActiveModel::Model
  
  Update = Ferret::Feature::Update
  
  delegate :adapter, :to => :configuration
  
  attr_accessor :subject_uri, :object_uri, :updates, :revision
  validates_presence_of :subject_uri, :object_uri, :updates, :revision
  
  define_model_callbacks :validate
  after_validate :validate_updates
  
  class << self
    def configuration=(config_name)
      @configuration = Ferret::Configuration.load(config_name) 
    end
    alias :set_configuration :configuration= 
  
    def configuration
      @configuration ||= Ferret::Configuration.load_default
    end
    
  end
  
  def initialize(attrs)
    raise "No FEATURE_TYPE constant defined for #{self.class.name.inspect}" unless self.class.const_defined?(:FEATURE_TYPE)
    super({
      'updates' => []
    }.merge(attrs))
  end
  
  def new?
    revision.nil? || revision == 0
  end
  
  def dirty?
    return true if new?
    return if !!updates.detect(&:dirty?)
  end
  
  def feature_type
    self.class::FEATURE_TYPE
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
  
  def as_json
    identifying_hash(true).merge({
      'updates' => updates.map(&:as_json)
    })
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
  
  private
  def adapter
    configuration.adapter  
  end
  
end