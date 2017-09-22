require 'sequel'
require 'rom'

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

        @config.commands(:user_stations) do
          define(:delete)
        end
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
