patch_user_stations_schema = Dry::Validation.Form do
  required(:user_id).filled(:int?)
  required(:stations).filled(:array?)
end

namespace '/api' do
  patch '/user_stations/:user_id' do
    authorize_admin? env
    
    user_id = params['user_id']

    # validation
    result = patch_user_stations_schema.call(@payload.merge({user_id: user_id}))
    return [500, json(errors: result.errors)] if result.failure?
    # get user
    user = @user_repo.active_user(user_id)
    return [500, json(message: 'User not existed')] unless user
    
    # delete existing values 
    user_stations_delete_cmd = @rom.commands[:user_stations][:delete]
    user_stations_delete_cmd.by_user_id(user_id).call
    # create new records
    station_ids = @payload[:stations]
    station_ids.each do |id|        
      @user_station_repo.create(user_id: user_id, station_id: id)
    end
    
    stations = @station_repo.by_user(user_id).to_a
   
    [200, json(stations: stations)]
  end
end
