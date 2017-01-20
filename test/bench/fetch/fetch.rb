require_relative '../bench_init'

context "Fetch entity from store for a stream that exists" do
  stream_name = EventStore::EntityStore::Controls::Writer.write_batch

  comment "Stream Name: #{stream_name}"

  id = EventSource::StreamName.get_id stream_name
  category = EventSource::StreamName.get_category stream_name

  store = EventStore::EntityStore::Controls::Store.example

  store.category = category

  entity = store.fetch id

  test "Entity is returned" do
    assert entity == EventStore::EntityStore::Controls::Entity.example
  end
end
