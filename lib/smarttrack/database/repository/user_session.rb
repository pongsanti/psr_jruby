module SmartTrack::Database::Repository
  class UserSession
    attr_reader :id, :token
  
    def initialize(attributes)
      @id, @token = attributes.values_at(:id, :token)
    end
  end

  class UserSessionRepo < ROM::Repository[:user_sessions]
    commands :create, delete: :by_pk

    def query_first(conditions)
      user_sessions.where(conditions).first
    end
  end
end