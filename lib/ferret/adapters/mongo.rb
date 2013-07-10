require 'mongo'
require File.expand_path("../../adapters", __FILE__)
require File.expand_path("../mongo/connect", __FILE__)
require File.expand_path("../mongo/feature", __FILE__)
require File.expand_path("../mongo/event", __FILE__)

class Ferret::Adapters::Mongo
  include Ferret::Adapters::Mongo::Connect
  include Ferret::Adapters::Mongo::Feature
  include Ferret::Adapters::Mongo::Event
  
  def initialize(configuration)
    @configuration = configuration
  end
  
end