module SmartTrack::Database::Repository
  class UserStationRepo < ROM::Repository[:user_stations]
    commands :create, update: :by_pk, delete: :by_pk

  end

end