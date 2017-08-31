require 'bcrypt'

module SmartTrack::Test
  module Helper
    def rom
      SmartTrack::Database::Container.resolve(:rom)
    end

    def create_user(email, password = 'xxx')
      user_model = SmartTrack::Model::User.new(rom)
      hash = BCrypt::Password.create(password)
      user = user_model.repo.create(email: email, password: hash)
    end

    def create_session(user, session_token)
      session_model = SmartTrack::Model::UserSession.new(rom)
      session_model.repo.create(
        token: session_model.generate_session_token,
        user_id: user.id,
        expired_at: Time.now + (60*60*24*30))
    end

    def create_user_session(email, session_token)
      user = create_user(email)
      create_session(user, session_token)
    end
  end
end