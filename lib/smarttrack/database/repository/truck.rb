module SmartTrack::Database::Repository
  class Truck
    attr_reader :id, :license_plate, :brand, :color,
    # user_trucks attributes  
    :user_truck_id, :start_at, :end_at,
    # tblcarsets attr
    :vid
    
    def initialize(attributes)
      @id = attributes[:Truck_ID]
      @license_plate = attributes[:License_Plate]
      @brand = attributes[:Brand]
      @color = attributes[:Color]

      @user_truck_id = attributes[:id]
      @start_at = attributes[:start_at]
      @end_at = attributes[:end_at]

      @vid = attributes[:vid]
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

      hash = hash.merge({vid: vid}) if vid

      hash.to_json
    end
  end

  class TruckRepo < ROM::Repository[:trucks]
    relations :users

    def all
      trucks.map_to(Truck).index.active
    end

    def users_with_trucks
      users.combine(many: trucks.for_users).to_a
    end

    def by_user user_id
      trucks.map_to(Truck).index
        .select_user_trucks.active_user_trucks
        .active.of_user(user_id)
    end

    def with_serial_sim plates
      trucks.index
      .select_tblcarsets_serial_sim
      .active
      .with_tblcarsets
      .by_plates(plates)
    end
    
    def with_vid plates
      trucks.index
      .select_tblcarsets_vid
      .active
      .with_tblcarsets
      .by_plates(plates)
    end
  end
end