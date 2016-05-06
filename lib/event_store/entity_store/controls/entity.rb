module EventStore
  module EntityStore
    module Controls
      module Entity
        class Example
          include Schema::DataStructure

          attribute :sum

          def ==(other)
            other.is_a?(self.class) && other.sum == sum
          end
        end

        module NotCached
          def self.example
            EventStore::EntityProjection::Controls::Entity.example
          end
        end

        module Cached
          def self.example
            Example.build :sum => sum
          end

          def self.add(store, id)
            entity = self.example
            version = Version::Cached.example

            store.cache.add id, entity, version, persisted_version: version
          end

          def self.sum
            1
          end
        end

        module Current
          def self.example
            Example.build :sum => sum
          end

          def self.sum
            12
          end
        end
      end
    end
  end
end
