get_user_stations_schema = Dry::Validation.Form do
  required(:user_id).filled(:int?)
end

namespace '/api' do
  get '/user_stations/:user_id' do
    authorize_admin? env
    
    user_id = params['user_id']
    # validation
    result = get_user_stations_schema.call(@payload.merge({user_id: user_id}))
    return [500, json(errors: result.errors)] if result.failure?

    # @user_station_repo.create(user_id: user_id, station_id: 1)
    # @user_station_repo.create(user_id: user_id, station_id: 2)
    
    dataset = @user_repo.stations_by_user(user_id)
    data = dataset.to_a
    # puts data.to_s
    
    [200, json(stations: data)]
  end
end
