require_relative '../bench_init'

context "Fetch with Includes" do
  stream_name = EventStore::EntityStore::Controls::Writer.write_batch

  id = EventStore::Messaging::StreamName.get_id stream_name
  category_name = EventStore::Messaging::StreamName.get_category stream_name

  store = EventStore::EntityStore::Controls::Store.example
  store.category_name = category_name

  test "Entity" do
    retrieved_entity, _ = store.get id, include: :id
    assert(!retrieved_entity.nil?)
  end

  context "Includes" do
    _, time, version, retrieved_id = store.get id, include: [:time, :version, :id]

    test "Time" do
      refute(time.nil?)
    end

    test "Version" do
      refute(version.nil?)
    end

    test "Id" do
      refute(retrieved_id.nil?)
    end
  end
end
