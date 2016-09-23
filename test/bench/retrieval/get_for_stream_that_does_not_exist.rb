# require_relative '../bench_init'

# context "Get entity from store" do
#   stream_name = SecureRandom.hex

#   id = EventStore::Messaging::StreamName.get_id stream_name
#   category_name = EventStore::Messaging::StreamName.get_category stream_name

#   store = EventStore::EntityStore::Controls::Store::Example.build

#   store.category_name = category_name

#   entity = store.get id

#   test "Entity is returned" do
#     assert entity == EventStore::EntityStore::Controls::Entity.example
#   end
# end
