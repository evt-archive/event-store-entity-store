require_relative '../bench_init'

context "Get with Includes" do
  stream_name = EventStore::EntityStore::Controls::Writer.write_batch

  id = EventSource::StreamName.get_id stream_name
  category = EventSource::StreamName.get_category stream_name

  store = EventStore::EntityStore::Controls::Store.example
  store.category = category

  test "Entity" do
    retrieved_entity, _ = store.fetch id, include: :id
    assert(!retrieved_entity.nil?)
  end

  context "Individual Includes" do
    test "ID" do
      _, id = store.fetch id, include: :id
      assert(!id.nil?)
    end

    test "Version" do
      _, version = store.fetch id, include: :version
      assert(!version.nil?)
    end

    test "Time" do
      _, time = store.fetch id, include: :time
      assert(!time.nil?)
    end
  end

  context "Permutation of Includes" do
    includes = [:time, :version, :id]

    [1, 2, 3].each do |n|
      context "Permutations of #{n}" do
        permutations = includes.permutation(n).to_a

        permutations.each do |includes|
          context "#{includes.join(', ')}" do
            results = store.fetch id, include: includes

            includes.each_with_index do |include, i|
              test "#{include}" do
                refute(results[i + 1].nil?)
              end
            end
          end
        end
      end
    end
  end
end
