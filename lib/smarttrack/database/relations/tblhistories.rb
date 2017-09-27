module SmartTrack::Database::Relations
  class Tblhistories < ROM::Relation[:sql]
    schema(:tblhistories) do
      attribute :vid, Types::String
      attribute :gps_datetime, Types::DateTime
      attribute :latitude, Types::Float
      attribute :longitude, Types::Float
      attribute :stationid, Types::String
    end

    def index
      select(:vid, :gps_datetime, :latitude, :longitude)
    end
  end
end