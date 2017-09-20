require 'sequel'
require 'rom'

Sequel.split_symbols = true

module SmartTrack
  module Database

    class Connection
      attr_reader :rom, :sequel, :config

      def initialize(db_url)
        rom_config(db_url)
        register_components

        @rom = ROM.container(config)
        @sequel = @rom.gateways[:default].connection
      end

      def rom_config(db_url)
        @config = ROM::Configuration.new(:sql, db_url)
      end

      def register_components()
        path = File.expand_path('lib/smarttrack/database')
        config.auto_registration(path, namespace: 'SmartTrack::Database')
      end
      
      #require_relative 'util'
      #include SmartTrack::Database::Util
    end

  end
end
