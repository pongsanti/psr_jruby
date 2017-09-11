require 'bcrypt'
require 'securerandom'

module SmartTrack::Test
  module Helper
    def rom
      SmartTrack::Database::Container.resolve(:rom)
    end

    def user_repo
      SmartTrack::Database::Container.resolve(:user_repo)
    end

    def session_repo
      SmartTrack::Database::Container.resolve(:session_repo)
    end

    def create_user(email, password = 'xxx')
      hash = BCrypt::Password.create(password)
      user = user_repo.create(email: email, password: hash)
    end

    def create_admin_user(email, password = 'xxx')
      hash = BCrypt::Password.create(password)
      user = user_repo.create(email: email, password: hash, admin: true)
    end

    def create_session(user, session_token = SecureRandom.uuid)
      session_repo.create(
        token: session_token,
        user_id: user.id,
        expired_at: Time.now + (60*60*24*30))
    end

    def create_user_session(email, session_token)
      user = create_user(email)
      create_session(user, session_token)
    end

    def create_admin_user_session(email, session_token)
      user = create_admin_user(email)
      create_session(user, session_token)
    end
  end
end