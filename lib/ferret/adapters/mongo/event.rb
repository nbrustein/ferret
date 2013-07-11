module Ferret::Adapters; end
class Ferret::Adapters::Mongo
  module Event
    
    def events_collection
      collection_name = @configuration['events_collection'] || 'events'
      collection(collection_name)
    end
    
    def find_event(key)
      if doc = events_collection.find_one('key' => key)
        doc.delete('_id')
        doc
      end
    end

    def save_event(event)
      # FIXME: eventually, we may want to support a case where
      # an event can be updated and we need to worry about asynchronous
      # stuff.  For now, assume each event gets saved once
      events_collection.save(event.as_json)
    end

    # to update a feature: load it up with only the last update.
    # - if the last update is earlier than the time of the new update, then 
    #   just push it on the end, so long as the revision is still current
    # - if the last update is later than the time of the new update, then load up
    #   all updates, re-calculate, and re-save the whole document
    
  end
end