require_relative '../password'

module SmartTrack  
  module Operation
    
    ONE_MONTH_IN_MS = (60*60*24*30)
    
    def find_user_by_id(id)
      User.where(id: id).first
    end

    def find_user(email)
      return User.where(email: email).first
    end
  
    def password_matched(user, password)
      email = user.email
      hash = new_password_instance(user.password)
      return hash == password
    end

    def manager_user_session(user, token, expired_at = Time.now + ONE_MONTH_IN_MS)
      user.user_session.delete if user.user_session
      insert_user_session(user, token, expired_at)
    end

    def insert_user_session(user, token, expired_at = Time.now + ONE_MONTH_IN_MS)
      session = UserSession.new(token: token, expired_at: expired_at).save
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
