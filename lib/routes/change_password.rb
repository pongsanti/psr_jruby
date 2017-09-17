change_password_schema = Dry::Validation.Form do
  required(:old_password).filled
  required(:new_password).filled(min_size?: SmartTrack::Constant::PASSWORD_MIN_SIZE)
end

namespace '/api' do
  post '/change_password' do
    authorize? env

    # validation
    result = change_password_schema.call(@payload)
    return [500, json(errors: result.errors)] if result.failure?

    unless @util.password_matched(@user.password, @payload[:old_password])
      return [500, json(message: 'password incorrect')]
    end

    new_password_hash = BCrypt::Password.create(@payload[:new_password])
    changeset = user_repo
      .changeset(@user.id, password: new_password_hash)
      .map(:touch)
    user_repo.update(@user.id, changeset)

    [200, json(result: "Password updated")]
  end
end
