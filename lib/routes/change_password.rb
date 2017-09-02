change_password_schema = Dry::Validation.Form do
  password_min_size = 8
  required(:new_password).filled(min_size?: password_min_size)
end

namespace '/api' do
  post '/change_password' do
    authorize? env

    # validation
    result = change_password_schema.call(@payload)
    return [500, json(errors: result.errors)] if result.failure?

    unless password_matched(@user.password, @payload[:old_password])
      raise UnAuthError, 'password incorrect'
    end

    new_password_hash = BCrypt::Password.create(@payload[:new_password])
    #DB.update_password(@user, new_password)
    changeset = user_repo
      .changeset(@user.id, password: new_password_hash)
      .map(:touch)
    user_repo.update(@user.id, changeset)

    [200, json(result: "Password updated")]
  end
end
