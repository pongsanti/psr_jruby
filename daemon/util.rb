def truck_arrival_at_station(plate, locations)
  locations.find do |loc|
    loc[:plate] == plate && loc[:stationid].to_i != 0
  end
end

def truck_departure_from_station(plate, locations)
  locations.find do |loc|
    loc[:plate] == plate && loc[:stationid].to_i == 0
  end
end

def station_for_user(user_stations, user_id, station_id)
  user_stations.any? do |us|
    us[:user_id] == user_id && us[:station_id] = station_id
  end
end

# def find_user_truck_by_id(user_trucks, id)
#   result = nil
#   arr = user_trucks.select do |hash|
#     hash[:id] == id
#   end

#   result = arr[0] if arr
# end