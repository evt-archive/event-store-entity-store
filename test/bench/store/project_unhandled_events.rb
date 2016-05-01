require_relative 'store_init'

context "Projection Doesn't Apply All Events in the Stream" do
  stream_name = EventStore::EntityStore::Controls::Writer.write_batch 'someEntity'

  id = EventStore::EntityStore::Controls::StreamName.id(stream_name)
  category_name = stream_name.split('-')[0]

  store = EventStore::EntityStore::Controls::Store::IncompleteApplicationStore.build
  store.category_name = category_name

  test "Version number increases for events that aren't applied" do
    store.get id
    record = store.cache.get id

    assert(record.version == 1)
  end
end
