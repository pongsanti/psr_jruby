post_users_schema = Dry::Validation.Form do
  display_name_min_size = 4

  required(:email).filled(format?: URI::MailTo::EMAIL_REGEXP)
  required(:password).filled(min_size?: SmartTrack::Constant::PASSWORD_MIN_SIZE )
  required(:display_name).filled(min_size?: display_name_min_size)
end

get_users_schema = Dry::Validation.Form do
  required(:page).maybe(:int?)
  required(:size).maybe(:int?)
end

namespace '/api' do
  get '/users' do
    authorize? env

    page = params['page'] || 1
    size = params['size'] || 10
    result = get_users_schema.call(page: page, size: size)
    return [500, json(errors: result.errors)] if result.failure?    

    users = @user_repo.active_users(size, page)
    [200, json(users)]
  end

  post '/users' do
    authorize? env

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
      password: create_password(@payload[:password])).map(:add_timestamps)
    user = @user_repo.create(changeset)
    
    #[201, json(result: user.to_h)]
    [201, json(message: 'OK')]
  end
end