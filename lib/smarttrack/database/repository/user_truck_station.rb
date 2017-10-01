module SmartTrack::Database::Repository
  class UserTruckStation
    attr_reader :stationname, :arrived_at, :departed_at
    
      def initialize(attributes)
        @stationname = attributes[:stationname]
        @arrived_at = attributes[:arrived_at]
        @departed_at = attributes[:departed_at]
      end
  
      def arrived_at
        @arrived_at.strftime('%F %T') if @arrived_at
      end
  
      def departed_at
        @departed_at.strftime('%F %T') if @departed_at
      end
      
      def to_json(options={})
        hash = {
          station_name: stationname,
          arrived_at: arrived_at,
          departed_at: departed_at
        }
        hash.to_json
      end
  end

  class UserTruckStationRepo < ROM::Repository[:user_truck_stations]
    def active_by_user_truck_id user_truck_id
      user_truck_stations
        .map_to(UserTruckStation)
        .active
        .by_user_truck(user_truck_id)
    end
  end

end