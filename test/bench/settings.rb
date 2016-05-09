require_relative './bench_init'

context "Entity store settings" do
  context "Varying the persistent store" do
    data_source = { :persistent_store => 'control_example' }
    settings = Settings.build data_source

    store = EventStore::EntityStore::Controls::Store::Example.build settings: settings

    assert store.cache.persistent_store.is_a?(EntityCache::Controls::Storage::Persistent::Example)
  end

  context "Varying the entity cache write behind delay" do
    data_source = { :write_behind_delay => 11 }
    settings = Settings.build data_source

    store = EventStore::EntityStore::Controls::Store::Example.build settings: settings

    assert store.cache.write_behind_delay == 11
  end

  context "Settings file exists" do
    settings = EventStore::EntityStore::Settings.build

    test "Persistent store is set to the value specified in the file" do
      persistent_store = settings.get :persistent_store

      assert persistent_store == 'none'
    end
  end

  context "Settings file does not exist" do
    settings_file = 'settings/entity_store.json'
    contents = File.read settings_file

    File.unlink settings_file

    begin
      settings = EventStore::EntityStore::Settings.build

      test "Persistent store is not specified" do
        persistent_store = settings.get :persistent_store

        assert persistent_store == nil
      end

      test "Write behind delay is not specified" do
        write_behind_delay = settings.get :write_behind_delay

        assert write_behind_delay == nil
      end

    ensure
      File.write settings_file, contents
    end
  end
end
