module SmartTrack::Database::Relations
  class Users < ROM::Relation[:sql]
    use :pagination

    schema(:users, infer: true) do
      associations do
        has_one :user_session
      end
    end

    def like(col, text)
      where(Sequel.like(col, "%#{text}%"))
    end

    def active
      where(deleted_at: nil)
    end
  end
end