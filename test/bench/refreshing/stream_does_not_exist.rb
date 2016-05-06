require_relative '../bench_init'

context "Refreshing non existent entity" do
  id = Controls::ID.get

  store = EventStore::EntityStore::Controls::Store.example
  SubstAttr::Substitute.(:cache, store)

  context "Version" do
    _, version = store.get id, include: :version

    test "Indicates no stream exists" do
      assert version == EntityCache::Record::NoStream.version
    end
  end
end
