namespace '/api' do
  get '/locations' do
    authorize? env

    current = DateTime.now

    ut = Sequel[:user_trucks]
    tr = Sequel[:trucks]
    rt = Sequel[:tblrealtimes]

    payload = @sequel[:user_trucks]
      .select(
        as(ut[:id], :user_truck_id),
        as(tr[:License_Plate], :license_plate),
        as(tr[:Brand], :brand),
        as(tr[:Color], :color),
        as(:server_datetime, :datetime),
        as(:lattitude, :latitude),
        :longitude, rt[:status], rt[:speed])
      .where(user_id: @user.id, ut[:deleted_at] => nil)
      .where { ut[:start_at] <= current }
      .where { ut[:end_at] >= current }
      .left_join(:trucks, Truck_ID: :truck_id, IsActive: 1)
      .left_join(:tblcarsets, plate: :License_Plate)
      .left_join(:tblrealtimes, serial_sim: :serial_sim)
      .order(ut[:id])
      .all
    
    locations = payload.map do |loc|
      datetime = loc[:datetime]
      loc[:datetime] = datetime_format(datetime) if datetime

      status = loc[:status]
      loc[:status] = tbl_realtime_status_text(status) if status
      
      loc
    end

    [200, json(locations: locations)]
  end
end

def tbl_realtime_status_text (status)
  case status
  when '20'; 'Stop'
  when '21'; 'Start'
  when '22'; 'OSpeed'
  when '23'; 'Idle'
  when '24'; 'GPSLost'
  when '25'; 'Normal'
  when '26'; 'LStop'
  else 'N/A'
  end
end