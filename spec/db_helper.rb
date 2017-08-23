module SmartTrack::Test
  module Helper
    def create_user(username, password = 'xxx')
      user = SmartTrack::User.new(username: username, password: password).save
    end

    def create_session(user, session_token)
      DB.insert_user_session(user, session_token)
    end

    def create_user_session(username, session_token)
      user = create_user(username)
      create_session(user, session_token)
    end
  end
end