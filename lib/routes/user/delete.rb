delete_user_schema = Dry::Validation.Form do
  required(:id).filled(:int?)
end

namespace '/api' do
  delete '/users/:id' do
    authorize_admin? env

    id = params['id']
    result = delete_user_schema.call(id: id)
    return [500, json(errors: result.errors)] if result.failure?

    user = @user_repo.active_user(id)
    return [500, json(message: 'User not existed')] unless user

    changeset = @user_repo.changeset(user.id, deleted_at: DateTime.now)
      .map(:touch)
    @user_repo.update(user.id, changeset)

    [200, json(message: 'OK')]
  end
end
