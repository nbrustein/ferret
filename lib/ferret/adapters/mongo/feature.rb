module Ferret::Adapters; end
class Ferret::Adapters::Mongo
  module Feature
    
    def features_collection
      collection_name = @configuration['features_collection'] || 'features'
      collection(collection_name)
    end
    
    def find_feature(key, options = {})
      if doc = features_collection.find_one({'key' => key}, find_options(options))
        prepare_doc(doc)
      end
    end
    
    def find_features(subject_uri, feature_type, object_uris, options = {})
      selector = {
        'subject_uri' => subject_uri,
        'feature_type' => feature_type
      }
      
      unless object_uris == :all
        selector['object_uri'] = {'$in' => object_uris}
      end
      
      docs = features_collection.find(selector, find_options(options))
      docs.map do |doc|
        prepare_doc(doc)
      end
    end

    def save_feature(feature)
      # FIXME: In each case, how do we detect and respond if the save fails?
      if feature.new?
        feature.revision += 1
        features_collection.save(feature.as_json)
      elsif feature.only_last_update_is_dirty?
        features_collection.update({'key' => feature.key}, {
          '$push' => {'updates' => feature.updates.last.as_json},
          '$inc' => {'revision' => 1}
        })
        feature.revision += 1
      elsif feature.all_updates_loaded?
        feature.revision += 1
        features_collection.update({'key' => feature.key}, feature.as_json)
      else
        # the problem is that we have one or more diirty updates 
        raise "something"
      end

      true
    end

    # to update a feature: load it up with only the last update.
    # - if the last update is earlier than the time of the new update, then 
    #   just push it on the end, so long as the revision is still current
    # - if the last update is later than the time of the new update, then load up
    #   all updates, re-calculate, and re-save the whole document
    
    private
    def prepare_doc(doc)
      doc.delete('_id')
      doc['updates'].each do |update|
        update['new'] = false
      end
      doc
    end
    
    private
    def find_options(options)
      find_options = {}
      if options['updates_limit']
        find_options[:fields] ||= {}
        find_options[:fields]['updates'] = { '$slice' => -options['updates_limit'] }
      end
      find_options
    end
  end
end