require_relative '../error/input_error'

namespace '/api' do
  post '/change_password' do
    authorize? env

    old_password = @payload['old_password']
    new_password = @payload['new_password']

    unless DB.password_matched(@user, old_password)
      raise UnAuthError, 'password incorrect'
    end

    if new_password.empty?
      raise SmartTrack::InputError, 'password is empty'
    end

    @user.password = create_password(@payload[new_password])    
    [200, json(result: "Password updated")]
  end
end