def active_user_trucks(db)
  now = DateTime.now
  user_trucks = db[:user_trucks]
    .select(:id, :user_id, Sequel[:user_trucks][:truck_id], :License_Plate)
    .where(deleted_at: nil)
    .where { start_at <= now }
    .where { end_at >= now }
    .left_join(:trucks, Truck_ID: :truck_id)
    .all  
end

def locations_by_plates(db, plates)
  histories = db[:tblhistories]
    .select(Sequel[:tblhistories][:vid], :plate, :gps_datetime,
      :latitude, :longitude, Sequel[:tblhistories][:stationid])
    .left_join(:tblcarsets, vid: :vid)
    .where(plate: plates)
    .order(Sequel.desc(:gps_datetime))
    .where { gps_datetime >= now - (3 * MINUTE) }
  
    location_plates = Set.new
    locations = []
    # collect only the latest location of each plate
    # eliminate all duplicates we got from the query
    histories.each do |h|
      plate = h[:plate]
    
      break if location_plates.size == plates.size
    
      unless location_plates.include? plate
        location_plates << plate
        locations << h
      end
    end

    locations
end

def user_stations_by_user_ids(db, user_ids)
  db[:user_stations]
    .select(:user_id, :station_id)
    .where(user_id: user_ids)
    .order(:user_id, :station_id)
    .all
end

def user_truck_stations_has_been_recorded(db, user_truck_id, station_id)
  db[:user_truck_stations]
    .select(:id, :user_truck_id, :station_id)
    .where(user_truck_id: user_truck_id, station_id: station_id)
    .where(departed_at: nil)
    .all
end

def insert_user_truck_stations(db, user_truck_id, station_id)
  now = DateTime.now
  db[:user_truck_stations]
    .insert(
      user_truck_id: user_truck_id,
      station_id: station_id,
      arrived_at: now,
      created_at: now)
end

def user_truck_stations_arrived_by_user_truck_ids(db, user_truck_ids)
  db[:user_truck_stations]
    .select(Sequel[:user_truck_stations][:id], :station_id,
      Sequel[:user_trucks][:user_id], :License_Plate)
    .where(user_truck_id: user_truck_ids,
      departed_at: nil,
      Sequel[:user_truck_stations][:deleted_at] => nil)
    .left_join(:user_trucks, id: :user_truck_id)
    .left_join(:trucks, Truck_ID: :truck_id)
    .all
end

def update_user_truck_stations_departed(db, user_truck_station_id)
  now = DateTime.now
  db[:user_truck_stations]
    .where(id: user_truck_station_id)
    .update(departed_at: now, updated_at: now)
end