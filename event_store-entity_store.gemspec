# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'event_store-entity_store'
  s.version = '0.4.0.0.pre1'
  s.summary = 'Store of entities that are projected from EventStore streams'
  s.description = ' '

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/eventide-project/event-store-entity-store'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.3.3'

  s.add_runtime_dependency 'evt-entity_cache', '~> 0.6.0'
  s.add_runtime_dependency 'evt-entity_store'
  s.add_runtime_dependency 'evt-messaging-event_store'

  s.add_development_dependency 'test_bench'
end
