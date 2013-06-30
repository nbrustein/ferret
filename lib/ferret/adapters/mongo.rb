require File.expand_path("../../adapters", __FILE__)

class Ferret::Adapters::Mongo
  
  def initialize(configuration)
    @configuration = configuration
  end
  
  def collection(collection_name)
    @collections ||= {}
    @collections[collection_name] ||= get_collection(collection_name)
  end
  
  def features_collection
    collection_name = @configuration['features_collection'] || 'features'
    collection(collection_name)
  end
  
  def get_collection(collection_name)
    connect unless @database
    @database.collection(collection_name)
  end
  
  # adapted from MongoMapper 0.12.0
  def connect
    env = @configuration
    options = {}
    
    if env['options'].is_a?(Hash)
      options = env['options'].symbolize_keys.merge(options)
    end

    if env.key?('ssl')
      options[:ssl] = env['ssl']
    end

    @connection = if env['hosts']
      if env['hosts'].first.is_a?(String)
        Mongo::MongoReplicaSetClient.new( env['hosts'], options )
      else
        Mongo::MongoReplicaSetClient.new( *env['hosts'].push(options) )
      end
    else
      port = env['port'] || 27017
      puts "Mongo::MongoClient.new(#{env['host']}, #{port}, #{options})"
      Mongo::MongoClient.new(env['host'], port, options)
    end

    @database = @connection.db(env['database'])
    @database.authenticate(env['username'], env['password']) if env['username'] && env['password']
  end
  
  def save_feature(feature)
    return false unless feature.dirty?
    
    # FIXME: In each case, how do we detect and respond if the save fails?
    if feature.new?
      features_collection.save(feature.as_json)
    elsif feature.only_last_update_is_dirty?
      features_collection.update(feature.identifying_hash(true), {
        '$push' => {'updates' => feature.dirty_update},
        '$inc' => {'revision' => 1}
      })
    elsif feature.all_updates_loaded?
      features_collection.update(feature.identifying_hash(true), feature.as_json)
    else
      raise "something"
    end
      
    true
  end
  
  # to update a feature: load it up with only the last update.
  # - if the last update is earlier than the time of the new update, then 
  #   just push it on the end, so long as the revision is still current
  # - if the last update is later than the time of the new update, then load up
  #   all updates, re-calculate, and re-save the whole document
  
  
end