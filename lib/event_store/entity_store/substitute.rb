module EventStore
  module EntityStore
    module Substitute
      def self.build
        EntityStore.new
      end

      class EntityStore
        def get(id, include: nil)
          record = records[id]

          record.destructure include
        end

        def add(id, entity, version=nil)
          version ||= 0

          record = EntityCache::Record.new id, entity, version

          records[id] = record
        end

        def records
          @records ||= Hash.new do |hash, id|
            hash[id] = EntityCache::Record.missing id
          end
        end
      end
    end
  end
end
