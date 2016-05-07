module EventStore
  module EntityStore
    def self.included(cls)
      cls.class_exec do
        include EventStore::Messaging::StreamName

        extend Build

        extend EntityMacro
        extend ProjectionMacro

        dependency :cache, EntityCache
        dependency :logger, Telemetry::Logger
      end
    end

    def get(id, include: nil)
      logger.trace "Getting entity (ID: #{id.inspect}, Entity Class: #{entity_class.name.inspect}, Include: #{include.inspect})"

      record = cache.get_record id

      entity = record.entity || new_entity

      current_version = refresh entity, id, record.version

      unless current_version.nil?
        record = cache.put(
          id,
          entity,
          current_version,
          record.persisted_version,
          record.persisted_time
        )
      end

      logger.debug "Get entity done (ID: #{id.inspect}, Entity Class: #{entity_class.name.inspect}, Include: #{include.inspect}, Version: #{record.version.inspect}, Time: #{record.time})"

      record.destructure include
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
        instance = new
        EntityCache.configure instance, entity_class, attr_name: :cache
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
  end
end
