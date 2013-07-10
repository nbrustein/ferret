class Ferret::Adapters::Mongo
  module Feature
    
    def features_collection
      collection_name = @configuration['features_collection'] || 'features'
      collection(collection_name)
    end
    
    def find_feature(key)
      if doc = features_collection.find_one('key' => key)
        doc.delete('_id')
        doc
      end
    end

    def save_feature(feature)
      return false unless feature.dirty?

      # FIXME: In each case, how do we detect and respond if the save fails?
      if feature.new?
        feature.revision += 1
        features_collection.save(feature.as_json)
      elsif feature.only_last_update_is_dirty?
        features_collection.update({'key' => feature.key}, {
          '$push' => {'updates' => feature.dirty_update},
          '$inc' => {'revision' => 1}
        })
        feature.revision += 1
      elsif feature.all_updates_loaded?
        feature.revision += 1
        features_collection.update({'key' => feature.key}, feature.as_json)
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
end