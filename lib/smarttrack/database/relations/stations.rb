module SmartTrack::Database::Relations
  class Stations < ROM::Relation[:sql]
    schema(:gps_test__tblstation, infer: true) do
      associations do
        
      end
    end

    def index
      select(:stationid, :stationname)
    end
  end
end