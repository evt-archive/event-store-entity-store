require_relative './bench_init'

context "Entity store settings" do
  context "Settings file exists" do
    settings = EventStore::EntityStore::Settings.build

    test "Write behind delay is set to the value specified in the file" do
      write_behind_delay = settings.get :write_behind_delay

      assert write_behind_delay == 111
    end
  end

  context "Settings file does not exist" do
    settings_file = 'settings/entity_store.json'
    contents = File.read settings_file

    File.unlink settings_file

    begin
      settings = EventStore::EntityStore::Settings.build

      test "Write behind delay is not specified" do
        write_behind_delay = settings.get :write_behind_delay

        assert write_behind_delay == nil
      end

    ensure
      File.write settings_file, contents
    end
  end
end
