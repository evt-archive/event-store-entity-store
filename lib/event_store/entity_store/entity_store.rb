module EventStore
  module EntityStore
    def self.included(cls)
      cls.class_exec do
        include ::EntityStore

        extend Build
        extend SnapshotMacro

        reader EventSource::EventStore::HTTP::Read

        attr_writer :category
      end
    end

    module Build
      def build(snapshot_interval: nil, session: nil)
        settings = Settings.instance

        instance = new

        write_behind_delay = snapshot_interval || settings.get(:write_behind_delay)

        EntityCache.configure(
          instance,
          entity_class,
          persistent_store: instance.snapshot_class,
          write_behind_delay: snapshot_interval,
          attr_name: :cache
        )

        EventSource::EventStore::HTTP::Session.configure instance, session: session

        instance
      end
    end

    module SnapshotMacro
      def self.extended(cls)
        cls.singleton_class.class_exec do
          prepend SnapshotMacro
        end
      end

      def snapshot(cls, interval=nil)
        interval ||= Settings.instance.get :write_behind_delay

        super cls, nil
      end
    end
  end
end
