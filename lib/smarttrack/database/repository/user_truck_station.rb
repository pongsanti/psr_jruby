module SmartTrack::Database::Repository
  class UserTruckStation

  end

  class UserTruckStationRepo < ROM::Repository[:user_truck_stations]
    def active_by_user_truck_id user_truck_id
      user_truck_stations
        .active
        .by_user_truck(user_truck_id)
    end
  end

end