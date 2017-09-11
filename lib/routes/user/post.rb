post_users_schema = Dry::Validation.Form do
  display_name_min_size = 4

  required(:email).filled(format?: URI::MailTo::EMAIL_REGEXP)
  required(:password).filled(min_size?: SmartTrack::Constant::PASSWORD_MIN_SIZE )
  required(:display_name).filled(min_size?: display_name_min_size)
  optional(:admin).filled(:bool?)
end

namespace '/api' do
  post '/users' do
    authorize_admin? env

    # validation
    result = post_users_schema.call(@payload)
    return [500, json(errors: result.errors)] if result.failure?    

    if @user_repo.find_by_email(@payload[:email])
      return [500, json(message: 'User already existed')]
    end

    # create user
    changeset = @user_repo.changeset(
      display_name: @payload[:display_name],
      email: @payload[:email],
      password: create_password(@payload[:password]),
      admin: str_to_bool(@payload[:admin])).map(:add_timestamps)
    user = @user_repo.create(changeset)
    
    #[201, json(result: user.to_h)]
    [201, json(message: 'OK')]
  end
end

def str_to_bool str
  str == 'true' || str == 't'
end