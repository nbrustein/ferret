class Ferret::Adapters::Mongo
  module Connect
    
    def collection(collection_name)
      @collections ||= {}
      @collections[collection_name] ||= get_collection(collection_name)
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
        Mongo::MongoClient.new(env['host'], port, options)
      end

      @database = @connection.db(env['database'])
      @database.authenticate(env['username'], env['password']) if env['username'] && env['password']
    end
    
  end
end