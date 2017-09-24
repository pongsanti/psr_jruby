module SmartTrack::Database::Relations
  class Trucks < ROM::Relation[:sql]
    schema(:trucks, infer: true) do
    end

    def index
      select(:Truck_ID, :License_Plate, :Brand, :Color, :IsActive)
    end

    def active
      where(IsActive: 1)
    end
  end
end