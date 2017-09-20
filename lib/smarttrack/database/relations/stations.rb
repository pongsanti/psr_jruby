module SmartTrack::Database::Relations
  class Stations < ROM::Relation[:sql]
    schema(:stations) do
      attribute :stationid, Types::Int
      attribute :stationname, Types::String
  
      primary_key :stationid

      associations do
        has_many :users, through: :user_stations
      end
    end

    def index
      select(:stationid, :stationname)
    end
  end
end