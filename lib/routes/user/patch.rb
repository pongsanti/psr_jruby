patch_users_schema = Dry::Validation.Form do
  display_name_min_size = 4

  required(:id).filled(:int?)
  optional(:email).filled(format?: URI::MailTo::EMAIL_REGEXP)
  optional(:display_name).filled(min_size?: display_name_min_size)
  optional(:admin).filled(:bool?)
end

namespace '/api' do
  patch '/users/:id' do
    authorize_admin? env

    id = params['id']
    # validation
    result = patch_users_schema.call(@payload.merge({id: id}))
    return [500, json(errors: result.errors)] if result.failure?    
    # get user
    user = @user_repo.active_user(id)
    return [500, json(message: 'User not existed')] unless user

    changeset_hash = {}
    email = @payload[:email]
    if email && user.email != email # new email's been sent to update
      if @user_repo.find_by_email(email)
        return [500, json(message: 'Email already existed')]
      end
      changeset_hash[:email] = email
    end

    changeset_hash[:display_name] = @payload[:display_name] if @payload[:display_name]
    changeset_hash[:admin] = @payload[:admin] || false
    
    # create user
    changeset = @user_repo.changeset(user.id, changeset_hash).map(:touch)
    @user_repo.update(user.id, changeset)
    
    [200, json(message: 'OK')]
  end
end