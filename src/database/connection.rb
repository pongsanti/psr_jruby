require 'sequel'

module SmartTrack
  class Database
    attr_reader :db

    def initialize(db_url)
      @db = Sequel.connect(db_url)
      set_extensions
      initialize_models
    end

    def set_extensions
      @db.extension :identifier_mangling
      @db.identifier_input_method = nil
      @db.identifier_output_method = nil
      @db.quote_identifiers = false      
    end

    def initialize_models
      require_relative 'model'
    end
    
    require_relative 'operation'
    include Operation
  end
end
