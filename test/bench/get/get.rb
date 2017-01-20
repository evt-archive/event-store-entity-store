require_relative '../bench_init'

context "Get entity from store" do
  stream_name = EventStore::EntityStore::Controls::Writer.write_batch

  id = EventSource::StreamName.get_id stream_name
  category_name = EventSource::StreamName.get_category stream_name

  store = EventStore::EntityStore::Controls::Store.example

  store.category_name = category_name

  entity = store.get id

  test "Entity is returned" do
    assert entity == EventStore::EntityStore::Controls::Entity.example
  end
end
