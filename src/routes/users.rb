namespace '/api' do
  post '/users' do
    authorize? env

    email = @payload["email"]
    if DB.find_user(email)
      return [500, json(message: "User already existed")]
    end

    user = SmartTrack::User.new(
      display_name: @payload["display_name"],
      email: @payload["email"],
      password: create_password(@payload["password"]))
    user.save
    
    [201, json(result: "OK")]
  end
end