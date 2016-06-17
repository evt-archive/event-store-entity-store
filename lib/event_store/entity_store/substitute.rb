module EventStore
  module EntityStore
    module Substitute
      def self.build
        EntityStore.new
      end

      class EntityStore
        def get(id, include: nil)
          record = records[id]

          if record
            record.destructure include
          else
            EntityCache::Record::NoStream.destructure include
          end
        end

        def get_version(id)
          _, version = get id, include: :version
          version
        end

        def put(id, entity, version=nil)
          version ||= 0

          record = EntityCache::Record.new id, entity, version

          records[id] = record
        end
        alias :add :put

        def records
          @records ||= {}
        end
      end
    end
  end
end
