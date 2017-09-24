module SmartTrack::Database::Repository
  class Truck
    attr_reader :id, :license_plate, :brand, :color,
    # user_trucks attributes  
    :start_at, :end_at
    
    def initialize(attributes)
      @id = attributes[:Truck_ID]
      @license_plate = attributes[:License_Plate]
      @brand = attributes[:Brand]
      @color = attributes[:Color]

      @start_at = attributes[:start_at]
      @end_at = attributes[:end_at]
    end
    
    def to_json(options={})
      hash = {
        id: id,
        license_plate: license_plate,
        brand: brand,
        color: color
      }

      hash = hash.merge({start_at: start_at}) if start_at
      hash = hash.merge({end_at: end_at}) if end_at

      hash.to_json
    end
  end

  class TruckRepo < ROM::Repository[:trucks]
    def all
      trucks.map_to(Truck).index.active
    end

    def by_user user_id
      trucks.map_to(Truck).index.select_user_trucks.active.of_user(user_id)
    end    
  end
end