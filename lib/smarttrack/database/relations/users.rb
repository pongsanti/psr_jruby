module SmartTrack::Database::Relations
  class Users < ROM::Relation[:sql]
    schema(:users, infer: true) do
      associations do
        has_one :user_session
      end
    end
  end
end