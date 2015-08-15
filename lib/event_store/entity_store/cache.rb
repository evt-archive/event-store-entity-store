module EventStore
  module EntityStore
    class Cache
      dependency :clock, Clock::UTC
      dependency :logger, Telemetry::Logger

      def records
        @records ||= {}
      end

      def self.build
        new.tap do |instance|
          Clock::UTC.configure instance
          Telemetry::Logger.configure instance
        end
      end

      def self.configure(receiver)
        instance = build
        receiver.cache = instance
        instance
      end

      def put(id, entity, version=nil, time=nil)
        version ||= 0
        time ||= clock.iso8601
        record = Record.new entity, id, version, time
        records[id] = record
        record
      end

      def get(id)
        logger.trace "Getting record from cache (ID: #{id})"

        record = records[id]

        unless record.nil?
          logger.debug "Cache hit: #{self.class.object_log_msg(record)} (ID: #{id})"
        else
          logger.debug "Cache miss (ID: #{id})"
        end

        record
      end

      def self.object_log_msg(object)
        if object.nil?
          return "(none)"
        else
          return object.class.name
        end
      end

      def self.logger
        @logger ||= Telemetry::Logger.build
      end

      Record = Struct.new(:entity, :id, :version, :time) do
        def age
          Clock::UTC.elapsed_milliseconds(time, Clock::UTC.now)
        end

        def destructure(includes=nil)
          includes ||= []
          includes = [includes] unless includes.is_a? Array

          response = []
          includes.each do |attribute|
            response << send(attribute)
          end

          if response.empty?
            return entity
          else
            return response.unshift(entity)
          end
        end
      end
    end
  end
end
