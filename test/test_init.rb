ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_COLOR'] ||= 'on'

if ENV['LOG_LEVEL']
  ENV['LOGGER'] ||= 'on'
else
  ENV['LOG_LEVEL'] ||= 'trace'
end

ENV['LOGGER'] ||= 'off'
ENV['LOG_OPTIONAL'] ||= 'on'
ENV['ENTITY_CACHE_SCOPE'] ||= 'exclusive'

puts RUBY_DESCRIPTION

require_relative '../init.rb'

require 'securerandom'
require 'test_bench'; TestBench.activate
require 'event_store/entity_store/controls'

require 'pp'
