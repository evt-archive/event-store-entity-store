require_relative '../bench_init'

context "Get, with Includes" do
  stream_name = EventStore::EntityStore::Controls::Writer.write_batch

  id = EventStore::Messaging::StreamName.get_id stream_name
  category_name = EventStore::Messaging::StreamName.get_category stream_name

  test "Entity" do
    store = EventStore::EntityStore::Controls::Store::Example.build
    store.category_name = category_name

    retrieved_entity, _ = store.get id, include: :id
    assert(!retrieved_entity.nil?)
  end

  test "ID" do
    store = EventStore::EntityStore::Controls::Store::Example.build
    store.category_name = category_name

    _, id = store.get id, include: :id
    assert(!id.nil?)
  end

  test "Version" do
    store = EventStore::EntityStore::Controls::Store::Example.build
    store.category_name = category_name

    _, version = store.get id, include: :version
    assert(!version.nil?)
  end

  test "Time" do
    store = EventStore::EntityStore::Controls::Store::Example.build
    store.category_name = category_name

    _, time = store.get id, include: :time
    assert(!time.nil?)
  end

  test "Two Includes" do
    store = EventStore::EntityStore::Controls::Store::Example.build
    store.category_name = category_name

    _, version, retrieved_id = store.get id, include: [:version, :id]
    assert(!version.nil?)
    assert(!retrieved_id.nil?)
  end

  test "Three Includes" do
    store = EventStore::EntityStore::Controls::Store::Example.build
    store.category_name = category_name

    _, time, version, retrieved_id = store.get id, include: [:time, :version, :id]
    assert(!time.nil?)
    assert(!version.nil?)
    assert(!retrieved_id.nil?)
  end
end
