module SmartTrack::Database::Repository
  class UserTruckRepo < ROM::Repository[:user_trucks]
    commands :create, update: :by_pk, delete: :by_pk

  end

end