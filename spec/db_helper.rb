module SmartTrack::Test
  module Helper
    def create_user(email, password = 'xxx')
      user = SmartTrack::User.new(email: email, password: password).save
    end

    def create_session(user, session_token)
      DB.insert_user_session(user, session_token)
    end

    def create_user_session(email, session_token)
      user = create_user(email)
      create_session(user, session_token)
    end
  end
end