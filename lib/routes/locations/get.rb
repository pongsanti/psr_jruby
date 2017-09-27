namespace '/api' do
  get '/locations' do
    authorize? env    
    # user allowed active trucks
    trucks = @truck_repo.by_user(@user.id).to_a
    return [200, json(locations: [])] if trucks.empty?
    
    # find all truck's plates
    plates = trucks.map { |t| t.license_plate }
    # find vids from truck's plates
    trucks_with_vid = @truck_repo.with_vid(plates).to_a
    return [200, json(locations: [])] if trucks_with_vid.empty?
    
    # find locations from vids
    locations = trucks_with_vid.map do |t|
      @tblhistory_repo.by_vid(t.vid).first
    end
    return [200, json(locations: [])] if locations.empty?

    # merge truck data with location data
    payload = trucks_with_vid.map do |t|
      loc = locations.select { |loc| loc.vid == t.vid } [0]
      t.to_h.merge({
        gps_datetime: loc.gps_datetime,
        latitude: loc.latitude,
        longitude: loc.longitude
      })
    end

    [200, json(locations: payload)]
  end
end
