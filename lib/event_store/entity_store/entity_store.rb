module EventStore
  module EntityStore
    def self.included(cls)
      cls.class_exec do
        include ::EntityStore::Log::Dependency
        include ::Messaging::StreamName

        substitute_class = Class.new(::EntityStore::Substitute)

        substitute_class.send :define_method, :entity_class do
          cls.entity_class
        end

        const_set :Substitute, substitute_class

        attr_accessor :session
        attr_accessor :new_entity_probe

        dependency :cache, EntityCache

        configure :store

        virtual :category
        virtual :reader_class
        virtual :projection_class
        virtual :snapshot_class
        virtual :snapshot_interval

        extend Build
        extend ::EntityStore::EntityMacro
        extend ::EntityStore::ProjectionMacro
        extend ::EntityStore::ReaderMacro
        extend SnapshotMacro

        reader EventSource::EventStore::HTTP::Read

        attr_writer :category
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

    def fetch(id, include: nil)
      res = get(id, include: include)

      if res.nil?
        res = new_entity
      end

      if res.is_a?(Array) && res[0].nil?
        res[0] = new_entity
      end

      res
    end

    def new_entity
      entity = if entity_class.respond_to? :build
        entity_class.build
      else
        entity_class.new
      end

      unless new_entity_probe.nil?
        new_entity_probe.(entity)
      end

      entity
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

      read = EventSource::EventStore::HTTP::Read.build(
        stream_name,
        position: starting_position,
        session: session
      )

      position = nil

      projection = projection_class.build entity

      read.() do |event_data|
        position = event_data.position
        projection.(event_data)
      end

      position
    end

    module Build
      def build(session: nil)
        settings = Settings.instance

        instance = new

        write_behind_delay = settings.get :write_behind_delay

        EntityCache.configure(
          instance,
          entity_class,
          persistent_store: snapshot_class,
          write_behind_delay: write_behind_delay,
          attr_name: :cache
        )

        EventSource::EventStore::HTTP::Session.configure instance, session: session

        instance
      end
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
