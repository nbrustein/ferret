require File.expand_path("../../ferret", __FILE__)

module Ferret::Adapters
  
  def self.get(name)
    {
      'mongodb' => Ferret::Adapters::Mongo
    }[name] || (raise Ferret::AdapterNotFound.new(name))
  end
end