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

    def of_user user_id
      join(:user_stations, station_id: :stationid, user_id: user_id)
    end
  end
end