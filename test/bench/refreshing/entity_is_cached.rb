require_relative '../bench_init'

context "Refreshing the entity when no data is cached" do
  stream_name = EventStore::EntityStore::Controls::Writer.write_batch
  category = EventStore::Messaging::StreamName.get_category stream_name
  id = EventStore::Messaging::StreamName.get_id stream_name

  store = EventStore::EntityStore::Controls::Store.example category: category
  SubstAttr::Substitute.(:cache, store)

  EventStore::EntityStore::Controls::Entity::Cached.add store, id

  entity = store.get id

  test "Second event is projected" do
    assert entity.sum == EventStore::EntityStore::Controls::Entity::Current.sum
  end

  context "Cache update" do
    control_id = id

    test "Entity" do
      control_entity = EventStore::EntityStore::Controls::Entity::Current.example

      assert store.cache do
        put? do |id, entity|
          id == control_id && entity == control_entity
        end
      end
    end

    test "Version is refreshed" do
      control_version = EventStore::EntityStore::Controls::Version::Current.example

      assert store.cache do
        put? do |id, _, version|
          id == control_id && version == control_version
        end
      end
    end

    test "Persisted version is set to previous persisted cache version" do
      control_persisted_version = EventStore::EntityStore::Controls::Version::Cached.example

      assert store.cache do
        put? do |id, _, _, persisted_version|
          id == control_id && persisted_version == control_persisted_version
        end
      end
    end
  end
end
