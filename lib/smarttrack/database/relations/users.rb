module SmartTrack::Database::Relations
  class Users < ROM::Relation[:sql]
    use :pagination

    schema(:users, infer: true) do
      associations do
        has_one :user_session
      end
    end
  end
end