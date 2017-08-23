module SmartTrack::Test
  module Helper
    def create_user(username)
      user = SmartTrack::User.new(username: username, password: 'xxx').save
    end

    def create_user_session(username, session_token)
      user = create_user(username)
      DB.insert_user_session(user, session_token)
    end
  end
end