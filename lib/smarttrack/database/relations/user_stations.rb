module SmartTrack::Database::Relations
  class UserStations < ROM::Relation[:sql]
    schema(:user_stations, infer: true) do
      associations do
        belongs_to :user,     foreign_key: :user_id
        belongs_to :station,  foreign_key: :station_id
      end
    end

    def by_user_id id
      where(user_id: id)
    end
  end
end