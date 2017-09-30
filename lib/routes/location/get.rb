namespace '/api' do
  get '/locations' do
    authorize? env    
    # user allowed active trucks
    trucks = @truck_repo.by_user(@user.id).to_a
    return [200, json(locations: [])] if trucks.empty?
    
    # find all truck's plates
    plates = trucks.map { |t| t.license_plate }
    # find serial_sims from truck's plates
    trucks_with_ss = @truck_repo.with_serial_sim(plates).to_a
    return [200, json(locations: [])] if trucks_with_ss.empty?
    
    # find locations from serial_sim
    locations = trucks_with_ss.map do |t|
      @tblrealtime_repo.by_serial_sim(t.serial_sim).first
    end
    return [200, json(locations: [])] if locations.empty?

    # merge truck data with location data
    payload = trucks_with_ss.map do |t|
      loc = locations.select { |loc| loc.serial_sim == t.serial_sim } [0]
      t.to_h.merge({
        datetime: loc.server_datetime,
        latitude: loc.lattitude,
        longitude: loc.longitude
      }) if loc
    end

    # downcase hash keys
    payload = payload.map { |p| downcase_hash(p) }

    [200, json(locations: payload)]
  end
end

def downcase_hash hash
  result = {}
  hash.each_pair do |k, v|
    result.merge!(k.downcase => v)
  end
  result
end
