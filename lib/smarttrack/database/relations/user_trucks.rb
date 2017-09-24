module SmartTrack::Database::Relations
  class UserTrucks < ROM::Relation[:sql]
    schema(:user_trucks, infer: true) do
      associations do
        belongs_to :user,   foreign_key: :user_id
        belongs_to :truck,  foreign_key: :truck_id
      end
    end

    def by_user_id id
      where(user_id: id)
    end

    def by_id id
      by_pk(id)
    end

    def active
      where(deleted_at: nil)
    end
  end
end