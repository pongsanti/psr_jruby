require 'rom'

module SmartTrack
  module Database

    class Connection
      attr_reader :rom, :sequel

      def initialize(db_url)
        @rom = ROM.container(:sql, db_url)
        @sequel = @rom.gateways[:default].connection
        #initialize_models
      end

      def initialize_models
        require_relative 'model'
      end
      
      #require_relative 'util'
      #include SmartTrack::Database::Util
    end

  end
end
