require 'rom'
require 'rom-sql'
require 'rom-repository'

module SmartTrack
  module Database
  end
end

require_relative 'database/connection'
require_relative 'database/repository'

module SmartTrack::Database
  class Container
    extend Dry::Container::Mixin
  end
end