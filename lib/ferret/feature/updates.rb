require File.expand_path("../../feature", __FILE__)

class Ferret::Feature::Updates
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include Enumerable
  
  attr_reader :updates, :loaded_range
  before_validation :validate_updates
  delegate :each, :last, :size, :first, :insert, :[], :slice, :to => :updates
  
  def self.from_hashes(update_hashes, load_options)
    updates = update_hashes.map do |hash|
      Ferret::Feature::Update.from_hash(hash)
    end
    
    if load_options == :last
      if updates.any?
        loaded_range = [updates.last.time, :now]
      else
        loaded_range = [:start_of_time, :now]
      end
    elsif load_options == :all
      loaded_range = [:start_of_time, :now]
    elsif load_options == :none
      loaded_range = []
    end
    
    new(updates, loaded_range)
  end
  
  def initialize(updates, loaded_range)
    @updates, @loaded_range = updates, loaded_range
  end
  
  def all_updates_loaded?
    loaded_range == [:start_of_time, :now]
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