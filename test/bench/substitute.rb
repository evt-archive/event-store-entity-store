require_relative './bench_init'

context "Substitute" do
  id = Controls::ID

  store = SubstAttr::Substitute.build EventStore::EntityStore

  context "Entity has not been added" do
    entity, version = store.get id, include: :version

    test "Entity is nil" do
      assert entity == nil
    end

    test "Version indicates no stream exists" do
      assert version == EntityCache::Record::NoStream.version
    end
  end

  context "Entity has been added" do
    control_entity = EventStore::EntityStore::Controls::Entity.example
    control_version = EventStore::EntityStore::Controls::Version.example

    store.add id, control_entity, control_version

    entity, version = store.get id, include: :version

    test "Entity is returned" do
      assert entity == control_entity
    end

    test "Version is returned" do
      assert version == control_version
    end
  end
end
