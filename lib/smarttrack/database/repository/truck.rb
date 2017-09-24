module SmartTrack::Database::Repository
  class Truck
    attr_reader :id, :license_plate, :brand, :color
    
    def initialize(attributes)
      @id = attributes[:Truck_ID]
      @license_plate = attributes[:License_Plate]
      @brand = attributes[:Brand]
      @color = attributes[:Color]
    end
    
    def to_json(options={})
      hash = {
        id: id,
        license_plate: license_plate,
        brand: brand,
        color: color
      }
      hash.to_json
    end
  end

  class TruckRepo < ROM::Repository[:trucks]
    def all
      trucks.map_to(Truck).index.active
    end
  end
end