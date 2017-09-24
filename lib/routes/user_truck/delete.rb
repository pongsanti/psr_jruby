delete_user_truck_schema = Dry::Validation.Form do
  required(:user_truck_id).filled(:int?)
end

namespace '/api' do
  delete '/user_trucks/:user_truck_id' do
    authorize_admin? env
    
    id = params['user_truck_id']
    # validation
    result = delete_user_truck_schema.call({user_truck_id: id})
    return [500, json(errors: result.errors)] if result.failure?

    # check record existence
    user_truck = @user_truck_repo.active_by_id(id).one
    return [500, json(message: 'User truck not existed')] unless user_truck

    # update
    changeset = @user_truck_repo.changeset(id, 
      deleted_at: DateTime.now).map(:touch)
    @user_truck_repo.update(id, changeset)
       
    [200, json(message: 'OK')]
  end
end
