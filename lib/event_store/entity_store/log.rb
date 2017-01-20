module EventStore
  module EntityStore
    class Log < ::Log
      def tag!(tags)
        tags << :event_store_entity_store
        tags << :entity_store
        tags << :verbose
      end
    end
  end
end
