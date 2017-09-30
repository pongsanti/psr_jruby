module SmartTrack::Database::Relations
  class Tblrealtimes < ROM::Relation[:sql]
    schema(:tblrealtimes) do
      attribute :server_datetime, Types::DateTime
      attribute :serial_sim, Types::String
      attribute :lattitude, Types::Float
      attribute :longitude, Types::Float
      attribute :stationid, Types::String
      attribute :speed, Types::String
    end

    def index
      select(:server_datetime, :serial_sim, :lattitude, :longitude)
    end

    def by_serial_sim ss
      where(serial_sim: ss)
    end
  end
end