namespace '/api' do
  get '/locations' do
    authorize? env

    current = DateTime.now

    ut = Sequel[:user_trucks]
    tr = Sequel[:trucks]

    payload = @sequel[:user_trucks]
      .select(
        as(ut[:id], :user_truck_id),
        as(tr[:License_Plate], :license_plate),
        as(tr[:Brand], :brand),
        as(tr[:Color], :color),
        as(:server_datetime, :datetime),
        as(:lattitude, :latitude),
        :longitude)
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
      loc
    end

    [200, json(locations: locations)]
  end
end
