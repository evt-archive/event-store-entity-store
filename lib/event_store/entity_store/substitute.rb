module EventStore
  module EntityStore
    class Substitute
      include EventStore::EntityStore

      def self.build
        new
      end

      def get(id, include: nil)
        record = records[id]

        if record
          record.destructure include
        else
          EntityCache::Record::NoStream.destructure include
        end
      end

      def fetch(id, include: nil)
        new_entity
      end

      def get_version(id)
        _, version = get id, include: :version
        version
      end

      def add(id, entity, version=nil)
        version ||= 0

        record = EntityCache::Record.new id, entity, version

        records[id] = record
      end
      alias :put :add

      def records
        @records ||= {}
      end
    end
  end
end
