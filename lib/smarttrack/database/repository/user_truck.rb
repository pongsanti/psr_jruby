module SmartTrack::Database::Repository
  class UserTruckRepo < ROM::Repository[:user_trucks]
    commands :create, update: :by_pk, delete: :by_pk

    def active_by_id id
      user_trucks.by_id(id).active
    end
  end

end