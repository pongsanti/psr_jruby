module SmartTrack::Database::Relations
  class UserTruckStations < ROM::Relation[:sql]
    schema(:user_truck_stations, infer: true) do
      associations do
        belongs_to :user_trucks,   foreign_key: :user_truck_id
      end
    end

    def by_id id
      by_pk(id)
    end

    def active
      where(deleted_at: nil)
    end

    def by_user_truck id
      where(user_truck_id: id)
        .left_join(:stations)
    end
  end
end