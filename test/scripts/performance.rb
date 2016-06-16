require_relative './scripts_init'

iterations = ENV.fetch('ITERATIONS') { '10' }.to_i

stream_name = EventStore::EntityStore::Controls::Writer.write_batch

category = EventStore::Messaging::StreamName.get_category stream_name
stream_id = EventStore::Messaging::StreamName.get_id stream_name

entity_store = EventStore::EntityStore::Controls::Store.example category: category

start_time = Clock.now

iterations.times do
  entity_store.get stream_id
  entity_store.cache.temporary_store.records.clear
end

finish_time = Clock.now

puts "Iterations: #{iterations}, StartTime: #{start_time.strftime '%H:%M:%S.3%N'}, FinishTime: #{finish_time.strftime '%H:%M:%S.%3N'}"

average_time_ms = Rational (finish_time - start_time) * 1000, iterations
ips = Rational iterations, finish_time - start_time

puts "AverageTime: %.2fms, InstructionsPerSecond: %.2f " % [average_time_ms, ips]
