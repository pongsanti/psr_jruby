login_schema = Dry::Validation.Form do
  required(:email).filled(format?: URI::MailTo::EMAIL_REGEXP)
  required(:password).filled
end

post '/login' do
  # validation
  result = login_schema.call(@payload)
  return [500, json(errors: result.errors)] if result.failure?

  # processing
  user = @user_repo.find_by_email(@payload[:email])

  if user && password_matched(user.password, @payload[:password])
    user_session = @session_repo.find_by_user_id(user.id)
    @session_repo.delete(user_session.id) if user_session
    
    changeset = @session_repo.changeset(
      token: generate_session_token,
      user_id: user.id,
      expired_at: Time.now + SmartTrack::Constant::ONE_MONTH_IN_MS).map(:add_timestamps)
    user_session = @user_repo.create(changeset)

    return [200, json(token: user_session.token,
      user: { display_name: user.display_name, email: user.email })
    ]
  end

  [500, json(message: 'Email or password incorrect')]
end

def generate_session_token
  @util.generate_session_token
end

def password_matched(user_pass_hash, external_password)
  @util.password_matched(user_pass_hash, external_password) 
end
