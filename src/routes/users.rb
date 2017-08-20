namespace '/api' do
  post '/users' do
    username = @payload["username"]
    if DB.db_find_user(username)
      return [500, json(message: "User already existed")]
    end

    user = SmartTrack::User.new(
      display_name: @payload["display_name"],
      username: @payload["username"],
      password: create_password(@payload["password"]))
    user.save
    
    [201, json(result: "OK")]
  end
end