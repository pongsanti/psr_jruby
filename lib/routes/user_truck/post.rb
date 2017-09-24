post_user_trucks_schema = Dry::Validation.Form do
  required(:user_id).filled(:int?)
  required(:truck_id).filled(:int?)
  required(:start_at).filled(:date_time?)
  required(:end_at).filled(:date_time?)
end

namespace '/api' do
  post '/user_trucks/:user_id' do
    authorize_admin? env

    user_id = params['user_id']

    # validation
    result = post_user_trucks_schema.call(@payload.merge({user_id: user_id}))
    return [500, json(errors: result.errors)] if result.failure?    

    # get user
    user = @user_repo.active_user(user_id)
    return [500, json(message: 'User not existed')] unless user
    
    # create user
    changeset = @user_truck_repo.changeset(
      user_id: user_id,
      truck_id: @payload[:truck_id],
      start_at: @payload[:start_at],
      end_at: @payload[:end_at]).map(:add_timestamps)
    user_truck = @user_truck_repo.create(changeset)
    
    #[201, json(result: user.to_h)]
    [201, json(message: 'OK')]
  end
end
