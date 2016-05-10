module EventStore
  module EntityStore
    def self.included(cls)
      cls.class_exec do
        configure :store

        include EventStore::Messaging::StreamName

        extend Build

        extend EntityMacro
        extend ProjectionMacro
        extend SnapshotMacro

        dependency :cache, EntityCache
        dependency :logger, Telemetry::Logger
      end
    end

    def get(id, include: nil)
      logger.trace "Getting entity (ID: #{id.inspect}, Entity Class: #{entity_class.name.inspect}, Include: #{include.inspect})"

      record = cache.get id

      if record
        entity = record.entity
        version = record.version
        persisted_version = record.persisted_version
        persisted_time = record.persisted_time
      else
        entity = new_entity
      end

      current_version = refresh entity, id, version

      unless current_version.nil?
        record = cache.put(
          id,
          entity,
          current_version,
          persisted_version,
          persisted_time
        )
      end

      logger.debug "Get entity done (ID: #{id.inspect}, Entity Class: #{entity_class.name.inspect}, Include: #{include.inspect}, Version: #{record&.version.inspect}, Time: #{record&.time.inspect})"

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

    def new_entity
      if entity_class.respond_to? :build
        entity_class.build
      else
        entity_class.new
      end
    end

    def next_version(version)
      if version
        version + 1
      else
        nil
      end
    end

    def refresh(entity, id, current_version)
      stream_name = self.stream_name id

      starting_position = next_version current_version

      projection_class.(entity, stream_name, starting_position: starting_position)
    end

    module Build
      def build
        settings = Settings.instance

        instance = new

        write_behind_delay = settings.get :write_behind_delay

        cache = EntityCache.configure(
          instance,
          entity_class,
          persistent_store: snapshot_class,
          write_behind_delay: write_behind_delay,
          attr_name: :cache
        )

        Telemetry::Logger.configure instance
        instance
      end
    end

    module EntityMacro
      def entity_macro(cls)
        define_singleton_method :entity_class do
          cls
        end

        define_method :entity_class do
          self.class.entity_class
        end
      end
      alias_method :entity, :entity_macro
    end

    module ProjectionMacro
      def projection_macro(cls)
        define_method :projection_class do
          cls
        end
      end
      alias_method :projection, :projection_macro
    end

    module SnapshotMacro
      def self.extended(cls)
        cls.singleton_class.virtual :snapshot_class
      end

      def snapshot_macro(cls)
        define_singleton_method :snapshot_class do
          cls
        end
      end

      alias_method :snapshot, :snapshot_macro
    end
  end
end
