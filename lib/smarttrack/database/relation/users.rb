module SmartTrack::Database::Relation
  class Users < ROM::Relation[:sql]
    schema(infer: true)
  end

  class UserSessions < ROM::Relation[:sql]
    schema(infer: true) do
      associations do
        belongs_to :user
      end
    end
  end
end