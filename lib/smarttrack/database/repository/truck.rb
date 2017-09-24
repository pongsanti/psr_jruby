module SmartTrack::Database::Repository
  class Truck
    attr_reader :id, :license_plate, :brand, :color,
    # user_trucks attributes  
    :user_truck_id, :start_at, :end_at
    
    def initialize(attributes)
      @id = attributes[:Truck_ID]
      @license_plate = attributes[:License_Plate]
      @brand = attributes[:Brand]
      @color = attributes[:Color]

      @user_truck_id = attributes[:id]
      @start_at = attributes[:start_at]
      @end_at = attributes[:end_at]
    end
    
    def start_at
      datetime_format @start_at if @start_at
    end

    def end_at
      datetime_format @end_at if @end_at
    end

    def datetime_format datetime
      datetime.strftime('%F %T')
    end

    def to_json(options={})
      hash = {
        id: id,
        license_plate: license_plate,
        brand: brand,
        color: color
      }

      hash = hash.merge({user_truck_id: user_truck_id}) if user_truck_id
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
      trucks.map_to(Truck).index
        .select_user_trucks.active_user_trucks
        .active.of_user(user_id)
    end    
  end
end