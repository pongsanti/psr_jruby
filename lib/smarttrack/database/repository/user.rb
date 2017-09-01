module SmartTrack::Database::Repository
  class User
    attr_reader :id, :email, :password, :user_session
  
    def initialize(attributes)
      @id, @email, @password, @user_session = attributes.values_at(
        :id, :email, :password, :user_session)
    end
  end

  class UserRepo < ROM::Repository[:users]
    relations :user_sessions

    commands :create
    
    def query_first(conditions)
      users.combine(one: {user_session: user_sessions}).map_to(User).where(conditions).first
    end

    def find_by_email(email)
      query_first(email: email)
    end

  end
end