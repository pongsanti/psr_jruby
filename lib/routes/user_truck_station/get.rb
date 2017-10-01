get_uts_by_ut_id = Dry::Validation.Form do
  required(:user_truck_id).filled(:int?)
end

namespace '/api' do
  get '/user_truck_stations/user_truck/:id' do
    authorize? env
    
    user_truck_id = params['id']
    # validation
    result = get_uts_by_ut_id.call(@payload.merge({user_truck_id: user_truck_id}))
    return [500, json(errors: result.errors)] if result.failure?

    # get user
    uts = @uts_repo.active_by_user_truck_id(user_truck_id).to_a

    [200, json(uts: uts)]
  end
end
