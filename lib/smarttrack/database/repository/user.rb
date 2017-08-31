module SmartTrack::Database::Repository
  class User
    attr_reader :id, :email, :password
  
    def initialize(attributes)
      @id, @email, @password = attributes.values_at(:id, :email, :password)
    end
  end

  class UserRepo < ROM::Repository[:users]
    commands :create
    
    def query_first(conditions)
      users.map_to(User).where(conditions).first
    end

  end
end