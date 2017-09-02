module SmartTrack::Database::Relations
  class UserSessions < ROM::Relation[:sql]
    schema(:user_sessions, infer: true) do
      associations do
        belongs_to :user
      end
    end

    def index
      select(:id, :token, :expired_at)
    end
  end
end