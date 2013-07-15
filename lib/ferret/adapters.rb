require File.expand_path("../../ferret", __FILE__)

module Ferret::Adapters
  
  # note. adapters have to handle time inside of hashes.  So, if we want to
  # just drop a json blob into an hbase, cell, for example, we have to user
  # bson instead of json
  
  def self.get(name)
    {
      'mongodb' => Ferret::Adapters::Mongo
    }[name] || (raise Ferret::AdapterNotFound.new(name))
  end
end