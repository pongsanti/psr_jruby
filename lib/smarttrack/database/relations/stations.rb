module SmartTrack::Database::Relations
  class Stations < ROM::Relation[:sql]
    schema(:gps_test__tblstation, infer: true)

    def index
      select(:stationid, :stationname)
    end
  end
end