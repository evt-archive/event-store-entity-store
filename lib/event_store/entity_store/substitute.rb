module EventStore
  module EntityStore
    class Substitute
      include EventStore::EntityStore

      def self.build
        new
      end

      def self.define(store_class)
        substitute_class = Class.new(self)

        substitute_class.send :define_method, :entity_class do
          store_class.entity_class
        end

        store_class.class_eval do
          const_set :Substitute, substitute_class
        end

        substitute_class
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
