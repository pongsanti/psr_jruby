post '/login' do
  user = @user_repo.find_by_email(@payload['email'])

  if user && password_matched(user.password, @payload['password'])
    user_session = @session_repo.find_by_user_id(user.id)
    @session_repo.delete(user_session.id) if user_session
    
    changeset = @session_repo.changeset(
      token: generate_session_token,
      user_id: user.id,
      expired_at: Time.now + (60*60*24*30)).map(:add_timestamps)
    user_session = @user_repo.create(changeset)

    return [200, json(token: user_session.token)]
  end

  [500, json(message: 'Email or password incorrect')]
end

def generate_session_token
  SecureRandom.uuid
end

def password_matched(user_pass_hash, external_password)
  hash = BCrypt::Password.new(user_pass_hash)
  return hash == external_password  
end