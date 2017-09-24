get_user_trucks_schema = Dry::Validation.Form do
  required(:user_id).filled(:int?)
end

namespace '/api' do
  get '/user_trucks/:user_id' do
    authorize_admin? env
    
    user_id = params['user_id']
    # validation
    result = get_user_trucks_schema.call(@payload.merge({user_id: user_id}))
    return [500, json(errors: result.errors)] if result.failure?

    # get user
    user = @user_repo.active_user(user_id)
    return [500, json(message: 'User not existed')] unless user

    trucks = @truck_repo.by_user(user_id).to_a
   
    [200, json(trucks: trucks)]
  end
end
