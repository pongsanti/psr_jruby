module SmartTrack::Database::Repository
  class UserSession
    attr_reader :id, :token
  
    def initialize(attributes)
      @id, @token = attributes.values_at(:id, :token)
    end
  end

  class UserSessionRepo < ROM::Repository[:user_sessions]
    relations :users
    commands :create, update: :by_pk, delete: :by_pk
  
    def query_first(conditions)
      user_sessions.index.wrap(:user).where(conditions).first
    end
  
    def find_by_user_id(user_id)
      query_first(user_id: user_id)
    end
  
    def find_by_token(token)
      query_first(token: token)
    end
  end

end