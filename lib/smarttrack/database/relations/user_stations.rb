module SmartTrack::Database::Relations
  class UserStations < ROM::Relation[:sql]
    schema(:user_stations, infer: true) do
      associations do
        belongs_to :user
        belongs_to :gps_test__tblstation
      end
    end
  end
end