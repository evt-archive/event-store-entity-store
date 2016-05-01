module EventStore
  module EntityStore
    module Controls
      Projection = EventStore::EntityProjection::Controls::EntityProjection

      module Projection
        class IncompleteApplication
          include EventStore::EntityProjection
          include EventStore::EntityProjection::Controls::Message

          apply SomeMessage do |message|
            entity.some_attribute = message.some_attribute
          end
        end
      end
    end
  end
end
