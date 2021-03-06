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
      select(:Truck_ID, :License_Plate, :Brand, :Color)
    end

    def select_user_trucks
      select_append(user_trucks[:id], user_trucks[:start_at], user_trucks[:end_at])
    end

    def select_tblcarsets_vid
      select_append(tblcarsets[:vid])
    end

    def select_tblcarsets_serial_sim
      select_append(tblcarsets[:serial_sim])
    end

    def active_user_trucks
      current = DateTime.now
      where(user_trucks[:deleted_at] => nil)
      .where { user_trucks[:start_at] <= current }
      .where { user_trucks[:end_at] >= current }
    end

    def active
      where(IsActive: 1)
    end

    def of_user user_id
      join(:user_trucks, truck_id: :Truck_ID, user_id: user_id).qualified
    end

    def with_tblcarsets
      join(:tblcarsets, plate: :License_Plate).qualified
    end

    def by_plates plates
      where(License_Plate: plates)
    end
  end
end