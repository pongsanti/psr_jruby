module SmartTrack::Database::Repository
  class Station
    attr_reader :id, :name
    
    def initialize(attributes)
      @id = attributes[:stationid]
      @name = attributes[:stationname]
    end
    
    def to_json(options={})
      hash = {
        id: id,
        name: name
      }
      hash.to_json
    end
  end

  class StationRepo < ROM::Repository[:stations]  
    def all
      stations.map_to(Station).index
    end

    def by_user user_id
      stations.map_to(Station).of_user(user_id)
    end
  end
end