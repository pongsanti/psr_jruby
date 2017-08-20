require_relative '../password'

module SmartTrack
  module Operation
    def find_user_by_id(id)
      User.where(id: id).first
    end

    def find_user(username)
      return User.where(username: username).first
    end
  
    def password_matched(user, password)
      username = user.username
      hash = new_password_instance(user.password)
      return hash == password
    end

    def manager_user_session(user, token)
      user.user_session.delete if user.user_session
      insert_user_session(user, token)
    end

    def insert_user_session(user, token)
      session = UserSession.new(token: token).save
      user.user_session = session
    end

    def find_user_session(token)
      UserSession.where(token: token).first
    end

    def delete_user_session(token)
      session = find_user_session(token)
      session.delete if session
    end
  end
end
