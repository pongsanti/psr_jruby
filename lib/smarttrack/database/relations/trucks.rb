module SmartTrack::Database::Relations
  class Trucks < ROM::Relation[:sql]
    schema(:trucks) do
      attribute :Truck_ID,      Types::Int
      attribute :License_Plate, Types::String
      attribute :Brand,         Types::String
      attribute :Color,         Types::String
      attribute :IsActive,      Types::Int
  
      primary_key :Truck_ID

      associations do
        has_many :users, through: :user_trucks
      end
    end

    def index
      select(:Truck_ID, :License_Plate, :Brand, :Color, :IsActive)
    end

    def select_user_trucks
      select_append(user_trucks[:start_at], user_trucks[:end_at])
    end

    def active
      where(IsActive: 1)
    end

    def of_user user_id
      join(:user_trucks, truck_id: :Truck_ID, user_id: user_id).qualified
    end
  end
end